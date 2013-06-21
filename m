From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter/IPVS fixes for net
Date: Fri, 21 Jun 2013 02:38:39 +0200
Message-ID: <1371775121-9710-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59452 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758204Ab3FUAiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 20:38:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two fixes for Netfilter/IPVS, they are:

* A skb leak fix in fragmentation handling in case that helpers are in place,
  it occurs since the IPV6 NAT infrastructure, from Phil Oester.

* Fix SCTP port mangling in ICMP packets, from Julian Anastasov.

Specifically, the first one should find its path to -stable asap. I can take
care myself of it once this hits Linus' tree, let me know what you prefer.

You can pull these changes from:


Julian Anastasov (1):
  ipvs: SCTP ports should be writable in ICMP packets

Phil Oester (1):
  netfilter: nf_conntrack_ipv6: Plug sk_buff leak in fragment handling

 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/netfilter/ipvs/ip_vs_core.c                |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
1.7.10.4
