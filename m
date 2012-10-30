From: pablo@netfilter.org
Subject: [PATCH 0/3] netfilter updates for the net tree
Date: Tue, 30 Oct 2012 11:19:17 +0100
Message-ID: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains fixes for your net tree, two of them
are due to relatively recent changes, one has been a longstanding bug,
they are:

* Fix incorrect usage of rt_gateway in the H.323 helper, from
  Julian Anastasov.

* Skip re-route in nf_nat code for ICMP traffic. If CONFIG_XFRM is
  enabled, we waste cycles to look up for the route again. This problem
  seems to be there since really long time. From Ulrich Weber.

* Fix mismatching section in nf_conntrack_reasm, from Hein Tibosch.

You can pull this changes from:

git://1984.lsi.us.es/nf master

Thanks!

Hein Tibosch (1):
  netfilter: nf_defrag_ipv6: solve section mismatch in nf_conntrack_reasm

Julian Anastasov (1):
  netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper

Ulrich Weber (1):
  netfilter: nf_nat: don't check for port change on ICMP tuples

 net/ipv4/netfilter/iptable_nat.c        |    4 +++-
 net/ipv6/netfilter/ip6table_nat.c       |    4 +++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 net/netfilter/nf_conntrack_h323_main.c  |    3 ++-
 4 files changed, 10 insertions(+), 5 deletions(-)

-- 
1.7.10.4

