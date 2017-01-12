From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/2] More flexible BPF cb access
Date: Thu, 12 Jan 2017 11:51:31 +0100
Message-ID: <cover.1484214889.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33540 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdALKv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 05:51:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves BPF's cb access by allowing b/h/w/dw
access variants on it. For details, please see individual
patches.

Thanks!

v1 -> v2:
 - Fix typo in test case description spotted by Quentin
 - Rest as-is

Daniel Borkmann (2):
  bpf: pass original insn directly to convert_ctx_access
  bpf: allow b/h/w/dw access for bpf's cb in ctx

 include/linux/bpf.h                         |   7 +-
 kernel/bpf/verifier.c                       |  11 +-
 kernel/trace/bpf_trace.c                    |  15 +-
 net/core/filter.c                           | 176 ++++++-----
 tools/testing/selftests/bpf/test_verifier.c | 442 +++++++++++++++++++++++++++-
 5 files changed, 563 insertions(+), 88 deletions(-)

-- 
1.9.3
