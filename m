From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter updates for net tree
Date: Thu, 23 Feb 2012 01:02:22 +0100
Message-ID: <1329955346-2615-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following are four fixes for your net tree:

* One fix for NFQUEUE if used in bridge mode when GRO/GSO skbs
  are enqueued from Florian Westphal.

* One fix from Joerg Willmann to fix wrong alignment in ebtables
  on PPC.

* One fix for soft lockup for ctnetlink from Jozsef Kadlecsik.

* One fix for IPVS from Simon Horman.

Please, pull these changes from:

	git://1984.lsi.us.es/net nf

Thanks!

Florian Westphal (1):
  netfilter: nf_queue: fix queueing of bridged gro skbs

Joerg Willmann (1):
  netfilter: ebtables: fix alignment problem in ppc

Jozsef Kadlecsik (1):
  netfilter: ctnetlink: fix soft lockup when netlink adds new entries

Simon Horman (1):
  ipvs: fix matching of fwmark templates during scheduling

 include/linux/netfilter_bridge/ebtables.h |    4 +-
 net/netfilter/ipvs/ip_vs_core.c           |    2 +-
 net/netfilter/nf_conntrack_netlink.c      |   43 +++++++++++------------------
 net/netfilter/nf_queue.c                  |   40 +++++++++++++++++++++-----
 4 files changed, 51 insertions(+), 38 deletions(-)

-- 
1.7.7.3

