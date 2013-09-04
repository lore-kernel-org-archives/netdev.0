From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] netfilter updates for net-next
Date: Wed,  4 Sep 2013 15:00:21 +0200
Message-ID: <1378299625-4638-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following batch contains:

* Three fixes for the new synproxy target available in your
  net-next tree, from Jesper D. Brouer and Patrick McHardy.

* One fix for TCPMSS to correctly handling the fragmentation
  case, from Phil Oester. I'll pass this one to -stable.

You can pull this changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 5a17a390de7bdbcfff9b8f344273a886ca4cf8bf:

  net: make snmp_mib_free static inline (2013-09-02 21:00:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 1205e1fa615805c9efa97303b552cf445965752a:

  netfilter: xt_TCPMSS: correct return value in tcpmss_mangle_packet (2013-09-04 14:20:03 +0200)

----------------------------------------------------------------
Jesper Dangaard Brouer (2):
      netfilter: more strict TCP flag matching in SYNPROXY
      netfilter: SYNPROXY: let unrelated packets continue

Patrick McHardy (1):
      netfilter: synproxy_core: fix warning in __nf_ct_ext_add_length()

Phil Oester (1):
      netfilter: xt_TCPMSS: correct return value in tcpmss_mangle_packet

 net/ipv4/netfilter/ipt_SYNPROXY.c  |   10 +++++++---
 net/ipv6/netfilter/ip6t_SYNPROXY.c |   10 +++++++---
 net/netfilter/nf_synproxy_core.c   |    4 ++--
 net/netfilter/xt_TCPMSS.c          |    2 +-
 4 files changed, 17 insertions(+), 9 deletions(-)
