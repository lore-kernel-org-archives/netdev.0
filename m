From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 3/6] netfilter-ipv4: ternary operator layout
Date: Wed, 14 Oct 2015 23:17:05 +0100
Message-ID: <1444861028-21556-4-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:46074 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754207AbbJNWRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 18:17:17 -0400
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct whitespace layout of ternary operators in the netfilter-ipv4
code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv4/netfilter/arp_tables.c | 4 ++--
 net/ipv4/netfilter/ip_tables.c  | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 7300616..eb6663bd 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -186,7 +186,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, arpinfo->iniface,
-			arpinfo->invflags&ARPT_INV_VIA_IN ?" (INV)":"");
+			arpinfo->invflags & ARPT_INV_VIA_IN ? " (INV)" : "");
 		return 0;
 	}
 
@@ -195,7 +195,7 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	if (FWINV(ret != 0, ARPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, arpinfo->outiface,
-			arpinfo->invflags&ARPT_INV_VIA_OUT ?" (INV)":"");
+			arpinfo->invflags & ARPT_INV_VIA_OUT ? " (INV)" : "");
 		return 0;
 	}
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3be2a4d..08b7ab0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -102,7 +102,7 @@ ip_packet_match(const struct iphdr *ip,
 	if (FWINV(ret != 0, IPT_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ipinfo->iniface,
-			ipinfo->invflags&IPT_INV_VIA_IN ?" (INV)":"");
+			ipinfo->invflags & IPT_INV_VIA_IN ? " (INV)" : "");
 		return false;
 	}
 
@@ -111,7 +111,7 @@ ip_packet_match(const struct iphdr *ip,
 	if (FWINV(ret != 0, IPT_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ipinfo->outiface,
-			ipinfo->invflags&IPT_INV_VIA_OUT ?" (INV)":"");
+			ipinfo->invflags & IPT_INV_VIA_OUT ? " (INV)" : "");
 		return false;
 	}
 
@@ -120,7 +120,7 @@ ip_packet_match(const struct iphdr *ip,
 	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO)) {
 		dprintf("Packet protocol %hi does not match %hi.%s\n",
 			ip->protocol, ipinfo->proto,
-			ipinfo->invflags&IPT_INV_PROTO ? " (INV)":"");
+			ipinfo->invflags & IPT_INV_PROTO ? " (INV)" : "");
 		return false;
 	}
 
-- 
1.9.1
