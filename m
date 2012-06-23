From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter updates for net-next (upcoming 3.6), batch 4
Date: Sun, 24 Jun 2012 01:53:25 +0200
Message-ID: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following four patches provide Netfilter fixes for the cthelper
infrastructure that was recently merged mainstream, they are:

* two fixes for compilation breakage with two different configurations:

  - CONFIG_NF_NAT=m and CONFIG_NF_CT_NETLINK=y
  - NF_CONNTRACK_EVENTS=n and CONFIG_NETFILTER_NETLINK_QUEUE_CT=y

* two fixes for sparse warnings.

You can pull this changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Pablo Neira Ayuso (4):
  netfilter: nfq_ct_hook needs __rcu and __read_mostly
  netfilter: nfnetlink_queue: fix compilation with CONFIG_NF_NAT=m and CONFIG_NF_CT_NETLINK=y
  netfilter: nfnetlink_queue: fix sparse warning due to missing include
  netfilter: ctnetlink: fix compilation with NF_CONNTRACK_EVENTS=n

 include/linux/netfilter.h            |    6 +++++-
 net/ipv4/netfilter/nf_nat_core.c     |    6 ++++++
 net/netfilter/core.c                 |    5 ++++-
 net/netfilter/nf_conntrack_netlink.c |    5 +----
 net/netfilter/nfnetlink_queue_ct.c   |    9 +++++----
 5 files changed, 21 insertions(+), 10 deletions(-)

-- 
1.7.10

