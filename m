From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/35] netfilter: ip6_tables: improve if statements
Date: Sat, 17 Oct 2015 13:32:58 +0200
Message-ID: <1445081590-2924-24-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48425 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775AbbJQL01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:27 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Correct whitespace layout of if statements.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6_tables.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c57ddd3..99425cf 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -133,7 +133,7 @@ ip6_packet_match(const struct sk_buff *skb,
 /* ... might want to do something with class and flowlabel here ... */
 
 	/* look for the desired protocol header */
-	if((ip6info->flags & IP6T_F_PROTO)) {
+	if (ip6info->flags & IP6T_F_PROTO) {
 		int protohdr;
 		unsigned short _frag_off;
 
@@ -151,9 +151,9 @@ ip6_packet_match(const struct sk_buff *skb,
 				ip6info->proto);
 
 		if (ip6info->proto == protohdr) {
-			if(ip6info->invflags & IP6T_INV_PROTO) {
+			if (ip6info->invflags & IP6T_INV_PROTO)
 				return false;
-			}
+
 			return true;
 		}
 
-- 
2.1.4
