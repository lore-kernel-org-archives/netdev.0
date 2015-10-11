From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 6/7] netfilter-ipv6: improve if statements
Date: Sun, 11 Oct 2015 17:32:19 +0100
Message-ID: <1444581140-6255-7-git-send-email-ipm@chirality.org.uk>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:39506 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751594AbbJKQc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 12:32:28 -0400
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct whitespace layout of if statements.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 80f014a..bd660ec 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -133,7 +133,7 @@ ip6_packet_match(const struct sk_buff *skb,
 /* ... might want to do something with class and flowlabel here ... */
 
 	/* look for the desired protocol header */
-	if((ip6info->flags & IP6T_F_PROTO)) {
+	if (ip6info->flags & IP6T_F_PROTO) {
 		int protohdr;
 		unsigned short _frag_off;
 
@@ -151,7 +151,7 @@ ip6_packet_match(const struct sk_buff *skb,
 				ip6info->proto);
 
 		if (ip6info->proto == protohdr) {
-			if(ip6info->invflags & IP6T_INV_PROTO) {
+			if (ip6info->invflags & IP6T_INV_PROTO) {
 				return false;
 			}
 			return true;
-- 
1.9.1
