From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] Some BPF helper cleanups
Date: Fri,  9 Sep 2016 02:45:27 +0200
Message-ID: <cover.1473381476.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33173 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbcIIApo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains a couple of misc cleanups and improvements
for BPF helpers. For details please see individual patches. We
let this also sit for a few days with Fengguang's kbuild test
robot, and there were no issues seen (besides one false positive,
see last one for details).

Thanks!

Daniel Borkmann (4):
  bpf: minor cleanups in helpers
  bpf: add BPF_SIZEOF and BPF_FIELD_SIZEOF macros
  bpf: add own ctx rewriter on ifindex for clsact progs
  bpf: add BPF_CALL_x macros for declaring helpers

 include/linux/filter.h   |  64 ++++++++++++++++
 kernel/bpf/core.c        |   2 +-
 kernel/bpf/helpers.c     |  52 ++++---------
 kernel/bpf/stackmap.c    |   5 +-
 kernel/trace/bpf_trace.c |  87 +++++++++++-----------
 net/core/filter.c        | 188 ++++++++++++++++++++++-------------------------
 6 files changed, 213 insertions(+), 185 deletions(-)

-- 
1.9.3
