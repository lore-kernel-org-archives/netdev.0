From: pablo@netfilter.org
Subject: [PATCH 0/5] netfilter fixes for 3.5-rc4
Date: Fri, 29 Jun 2012 17:37:30 +0200
Message-ID: <1340984255-738-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following are 4 fixes and the update of the MAINTAINERS file
to point to my Netfilter trees.

They are:

* One refcount leak fix in IPVS IPv6 support from Eric Dumazet.

* One fix for interface comparison in ipset hash-netiface sets
  from Florian Westphal.

* One fix for a missing rcu_read_unlock in nfnetlink from
  Tomasz Bursztyka.

* One fix for a kernel crash if IPSET_CMD_NONE is set to ipset via
  nfnetlink, again from Tomasz Bursztyka.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Eric Dumazet (1):
  netfilter: ipvs: fix dst leak in __ip_vs_addr_is_local_v6

Florian Westphal (1):
  netfilter: ipset: fix interface comparision in hash-netiface sets

Pablo Neira Ayuso (1):
  netfilter: update location of my trees

Tomasz Bursztyka (2):
  netfilter: ipset: fix crash if IPSET_CMD_NONE command is sent
  netfilter: nfnetlink: fix missing rcu_read_unlock in nfnetlink_rcv_msg

 MAINTAINERS                                |    4 ++--
 net/netfilter/ipset/ip_set_core.c          |   12 +++++++++++
 net/netfilter/ipset/ip_set_hash_netiface.c |   32 ++++------------------------
 net/netfilter/ipvs/ip_vs_ctl.c             |   14 ++++++------
 net/netfilter/nfnetlink.c                  |    4 +++-
 5 files changed, 28 insertions(+), 38 deletions(-)

-- 
1.7.10

