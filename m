From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/33] netfilter: ipset: Sparse warning about shadowed variable fixed
Date: Fri,  4 Oct 2013 10:32:50 +0200
Message-ID: <1380875598-5250-6-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55421 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab3JDIdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:33:37 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

net/netfilter/ipset/ip_set_hash_ipportnet.c:275:20:
warning: symbol 'cidr' shadows an earlier one

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index f15f3e2..9a80d8b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -272,7 +272,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		if (ip > ip_to)
 			swap(ip, ip_to);
 	} else if (tb[IPSET_ATTR_CIDR]) {
-		u8 cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
 		if (!cidr || cidr > 32)
 			return -IPSET_ERR_INVALID_CIDR;
-- 
1.7.10.4
