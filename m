From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/04: netfilter fixes
Date: Wed, 27 May 2009 16:35:24 +0200 (MEST)
Message-ID: <20090527143521.4649.73610.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51321 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759814AbZE0OfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 10:35:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are four netfilter fixes for 2.6.30, containing:

- a patch from Jozsef to fix accepting invalid RST packets in TCP conntrack
- a patch from Pablo to properly propagate DCCP conntrack state changes
- a patch from Jesper to fix an invalid return value in a xt_hashlimit
  seq_file function
- another patch from Pablo to fix undersized skb allocation in nfnetlink_log

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 include/linux/netfilter/nf_conntrack_tcp.h |    4 ++++
 net/netfilter/nf_conntrack_proto_dccp.c    |    4 ++++
 net/netfilter/nf_conntrack_proto_tcp.c     |   18 ++++++++++++++++++
 net/netfilter/nfnetlink_log.c              |    6 ++++++
 net/netfilter/xt_hashlimit.c               |    2 +-
 5 files changed, 33 insertions(+), 1 deletions(-)

Jesper Dangaard Brouer (1):
      netfilter: xt_hashlimit does a wrong SEQ_SKIP

Jozsef Kadlecsik (1):
      netfilter: nf_ct_tcp: fix accepting invalid RST segments

Pablo Neira Ayuso (2):
      netfilter: nf_ct_dccp: add missing DCCP protocol changes in event cache
      netfilter: nfnetlink_log: fix wrong skbuff size	calculation
