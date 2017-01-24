From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/5] Misc BPF improvements
Date: Tue, 24 Jan 2017 01:06:25 +0100
Message-ID: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44962 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751885AbdAXAGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds various misc improvements to BPF, f.e. allowing
skb_load_bytes() helper to be used with filter/reuseport programs
to facilitate programming, test cases for program tag, etc. For
details, please see individual patches.

Thanks!

Daniel Borkmann (5):
  bpf: simplify __is_valid_access test on cb
  bpf: enable load bytes helper for filter/reuseport progs
  bpf: allow option for setting bpf_l4_csum_replace from scratch
  bpf: add prog tag test case to bpf selftests
  bpf: enable verifier to better track const alu ops

 include/uapi/linux/bpf.h                    |   1 +
 kernel/bpf/verifier.c                       |  64 ++++++---
 net/core/filter.c                           |  63 ++++-----
 tools/testing/selftests/bpf/Makefile        |   4 +-
 tools/testing/selftests/bpf/test_tag.c      | 202 ++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/test_verifier.c |  82 +++++++++++
 6 files changed, 364 insertions(+), 52 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_tag.c

-- 
1.9.3
