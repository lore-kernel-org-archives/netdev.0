From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] BPF pruning follow-up
Date: Tue, 23 May 2017 18:30:40 +0200
Message-ID: <cover.1495556127.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47611 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763215AbdEWQbU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:31:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to fix incorrect pruning when alignment tracking is
in use and to properly clear regs after call to not leave stale
data behind. For details, please see individual patches.

Thanks!

Daniel Borkmann (3):
  bpf: fix incorrect pruning decision when alignment must be tracked
  bpf: properly reset caller saved regs after helper call and ld_abs/ind
  bpf: add various verifier test cases

 include/linux/filter.h                      |  10 ++
 kernel/bpf/verifier.c                       |  44 +++--
 tools/include/linux/filter.h                |  10 ++
 tools/testing/selftests/bpf/test_verifier.c | 239 +++++++++++++++++++++++++++-
 4 files changed, 275 insertions(+), 28 deletions(-)

-- 
1.9.3
