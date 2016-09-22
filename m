From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] Few minor BPF helper improvements
Date: Fri, 23 Sep 2016 01:28:34 +0200
Message-ID: <cover.1474586162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42473 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757295AbcIVX2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:28:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a few minor improvements around BPF helpers, first one is a
fix but given this late stage and that it's not really a critical
one, I think net-next is just fine. For details please see the
individual patches.

Thanks!

Daniel Borkmann (3):
  bpf: use skb_to_full_sk helper in bpf_skb_under_cgroup
  bpf: use bpf_get_smp_processor_id_proto instead of raw one
  bpf: add helper to invalidate hash

 include/uapi/linux/bpf.h |  7 +++++++
 net/core/filter.c        | 22 +++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletion(-)

-- 
1.9.3
