From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Two BPF smap related followups
Date: Thu, 17 Aug 2017 17:22:35 +0200
Message-ID: <cover.1502983087.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60882 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753136AbdHQPWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixing preemption imbalance and consolidating prologue
generation. Thanks!

Daniel Borkmann (2):
  bpf: don't enable preemption twice in smap_do_verdict
  bpf: reuse tc bpf prologue for sk skb progs

 kernel/bpf/sockmap.c |  3 ++-
 net/core/filter.c    | 47 ++++++++++-------------------------------------
 2 files changed, 12 insertions(+), 38 deletions(-)

-- 
1.9.3
