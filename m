From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 3/6] ipv6: netfilter: remove unnecessary braces
Date: Sat, 25 Apr 2015 10:26:57 +0100
Message-ID: <1429954020-11763-4-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36716 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758807AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove braces from a few if statements where not required.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c         | 3 +--
 net/ipv6/netfilter/nf_conntrack_reasm.c | 4 ++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 82d53d5..1f8a503 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -151,9 +151,8 @@ ip6_packet_match(const struct sk_buff *skb,
 				ip6info->proto);
 
 		if (ip6info->proto == protohdr) {
-			if (ip6info->invflags & IP6T_INV_PROTO) {
+			if (ip6info->invflags & IP6T_INV_PROTO)
 				return false;
-			}
 			return true;
 		}
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 07d8534..a7f6977 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -527,9 +527,9 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 		struct ipv6_opt_hdr hdr;
 		int hdrlen;
 
-		if (!ipv6_ext_hdr(nexthdr)) {
+		if (!ipv6_ext_hdr(nexthdr))
 			return -1;
-		}
+
 		if (nexthdr == NEXTHDR_NONE) {
 			pr_debug("next header is none\n");
 			return -1;
-- 
1.9.1
