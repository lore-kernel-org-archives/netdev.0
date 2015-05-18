From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/21] netfilter: ipset: Fix sparse warning
Date: Mon, 18 May 2015 18:25:04 +0200
Message-ID: <1431966324-4494-2-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43983 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185AbbERQUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:41 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

"warning: cast to restricted __be32" warnings are fixed

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_ipmark.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 7abf978..2ec4ac5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -128,7 +128,7 @@ hash_ipmark4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+	e.mark = ntohl(nla_get_be32(tb[IPSET_ATTR_MARK]));
 	e.mark &= h->markmask;
 
 	if (adt == IPSET_TEST ||
@@ -263,7 +263,7 @@ hash_ipmark6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	e.mark = ntohl(nla_get_u32(tb[IPSET_ATTR_MARK]));
+	e.mark = ntohl(nla_get_be32(tb[IPSET_ATTR_MARK]));
 	e.mark &= h->markmask;
 
 	if (adt == IPSET_TEST) {
-- 
1.7.10.4
