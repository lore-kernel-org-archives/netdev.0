From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] netfilter fixes for net
Date: Fri, 19 Apr 2013 03:16:00 +0200
Message-ID: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

If time allows, please consider pulling the following patchset contains two
late Netfilter fixes, they are:

* Skip broadcast/multicast locally generated traffic in the rpfilter,
  (closes netfilter bugzilla #814), from Florian Westphal.

* Fix missing elements in the listing of ipset bitmap ip,mac set
  type with timeout support enabled, from Jozsef Kadlecsik.

The following changes since commit c2d421e171868586939c328dfb91bab840fe4c49:

  netfilter: nf_nat: fix race when unloading protocol modules (2013-04-12 11:46:31 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f83a7ea2075ca896f2dbf07672bac9cf3682ff74:

  netfilter: xt_rpfilter: skip locally generated broadcast/multicast, too (2013-04-19 00:11:59 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: xt_rpfilter: skip locally generated broadcast/multicast, too

Jozsef Kadlecsik (1):
      netfilter: ipset: bitmap:ip,mac: fix listing with timeout

 net/ipv4/netfilter/ipt_rpfilter.c         |    8 +++++++-
 net/ipv6/netfilter/ip6t_rpfilter.c        |    8 +++++++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    6 +++++-
 3 files changed, 19 insertions(+), 3 deletions(-)

