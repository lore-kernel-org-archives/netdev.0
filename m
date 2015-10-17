From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/35] netfilter: ip6_tables: ternary operator layout
Date: Sat, 17 Oct 2015 13:32:57 +0200
Message-ID: <1445081590-2924-23-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48420 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbbJQL00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:26 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Correct whitespace layout of ternary operators in the netfilter-ipv6
code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6_tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 62190c3..c57ddd3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -117,7 +117,7 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ip6info->iniface,
-			ip6info->invflags&IP6T_INV_VIA_IN ?" (INV)":"");
+			ip6info->invflags & IP6T_INV_VIA_IN ? " (INV)" : "");
 		return false;
 	}
 
@@ -126,7 +126,7 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ip6info->outiface,
-			ip6info->invflags&IP6T_INV_VIA_OUT ?" (INV)":"");
+			ip6info->invflags & IP6T_INV_VIA_OUT ? " (INV)" : "");
 		return false;
 	}
 
-- 
2.1.4
