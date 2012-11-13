From: pablo@netfilter.org
Subject: [PATCH 0/3] netfilter updates for net-next
Date: Tue, 13 Nov 2012 01:06:40 +0100
Message-ID: <1352765203-4160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45999 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753809Ab2KMAG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 19:06:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following three patches contain updates for your net-next tree,
they include:

* Little cleanup for IPVS the use of a strange notation to assign the
  conntrack object, from Alan Cox.

* getsockopt support to obtain the original IPv6 address after NAT,
  similar to the one that IPv4 provides, from Florian Westphal.

* Another little cleanup for nf_nat to save a couple of lines by using
  PTR_RET, from Wu Fengguang.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Alan Cox (1):
  ipvs: remove silly double assignment

Florian Westphal (1):
  netfilter: ipv6: add getsockopt to retrieve origdst

Wu Fengguang (1):
  netfilter: nf_nat: use PTR_RET

 include/uapi/linux/in6.h                       |    1 +
 include/uapi/linux/netfilter_ipv6/ip6_tables.h |    3 ++
 net/ipv4/netfilter/iptable_nat.c               |    4 +-
 net/ipv6/netfilter/ip6table_nat.c              |    4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   61 ++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_nfct.c                |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                |    8 ++--
 7 files changed, 72 insertions(+), 11 deletions(-)

-- 
1.7.10.4
