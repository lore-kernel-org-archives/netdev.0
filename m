From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] Two BPF fixes
Date: Sat, 17 Dec 2016 01:54:47 +0100
Message-ID: <cover.1481935106.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50832 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932517AbcLQAzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:55:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set contains two BPF fixes for net, one that addresses the
complaint from Geert wrt static allocations, and the other is a
fix wrt mem accounting that I found recently during testing.

Thanks!

Daniel Borkmann (2):
  bpf: dynamically allocate digest scratch buffer
  bpf: fix overflow in prog accounting

 include/linux/bpf.h    |  2 +-
 include/linux/filter.h | 17 ++++++++--
 kernel/bpf/core.c      | 88 ++++++++++++++++++++++++++++++++++++++++++--------
 kernel/bpf/syscall.c   | 27 +---------------
 kernel/bpf/verifier.c  |  6 ++--
 5 files changed, 94 insertions(+), 46 deletions(-)

-- 
1.9.3
