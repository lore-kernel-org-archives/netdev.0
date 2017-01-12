From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] More flexible BPF cb access
Date: Thu, 12 Jan 2017 02:21:31 +0100
Message-ID: <cover.1484182858.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45812 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762813AbdALBqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 20:46:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves BPF's cb access by allowing b/h/w/dw
access variants on it. For details, please see individual
patches.

Thanks!

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
