From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/04: netfilter fixes
Date: Tue,  5 May 2009 18:47:42 +0200 (MEST)
Message-ID: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches fix a couple of netfilter bugs:

- missing inclusion of linux/types.h in xt_LED.h

- an incorrect length check in the ipv6header match, causing
  mismatches on packets ending with NEXTHDR_NONE

- an incorrect check in the new cluster match, causing rules using
  32 nodes to fail loading

- incorrect ctnetlink event types for user-generated events

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 include/linux/netfilter/xt_LED.h     |    2 ++
 include/linux/netfilter/xt_cluster.h |    2 ++
 net/ipv6/netfilter/ip6t_ipv6header.c |    6 +++---
 net/netfilter/xt_cluster.c           |    8 +++++++-
 4 files changed, 14 insertions(+), 4 deletions(-)

Christoph Paasch (1):
      netfilter: ip6t_ipv6header: fix match on packets ending with NEXTHDR_NONE

Pablo Neira Ayuso (1):
      netfilter: xt_cluster: fix use of cluster match with 32 nodes

Patrick McHardy (1):
      netfilter: add missing linux/types.h include to xt_LED.h
