#!/usr/bin/env bash
set -euxo pipefail

PATCH_FILE="${1:?Usage: apply_patch_strict.sh <patch-file>}"
test -f "${PATCH_FILE}"

if ! patch --batch --forward --dry-run -p1 -i "${PATCH_FILE}"; then
  echo "::error::Dry-run failed for patch: ${PATCH_FILE}"
  REJ_FILE="$(mktemp)"
  if patch --batch --forward -p1 -i "${PATCH_FILE}" -r "${REJ_FILE}"; then
    :
  fi
  echo "================ REJECTED HUNKS (${PATCH_FILE}) ================"
  if [ -s "${REJ_FILE}" ]; then
    cat "${REJ_FILE}"
  else
    echo "(patch failed before writing rejected hunks; inspect patch output above)"
  fi
  echo "================================================================"
  rm -f "${REJ_FILE}"
  exit 1
fi

patch --batch --forward -p1 -i "${PATCH_FILE}"
