From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 5/7] netfilter-ipv6: ternary operator layout
Date: Sun, 11 Oct 2015 17:32:18 +0100
Message-ID: <1444581140-6255-6-git-send-email-ipm@chirality.org.uk>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct whitespace layout of ternary operators in the netfilter-ipv6
code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 62190c3..80f014a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -117,7 +117,7 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
 		dprintf("VIA in mismatch (%s vs %s).%s\n",
 			indev, ip6info->iniface,
-			ip6info->invflags&IP6T_INV_VIA_IN ?" (INV)":"");
+			ip6info->invflags&IP6T_INV_VIA_IN ? " (INV)" : "");
 		return false;
 	}
 
@@ -126,7 +126,7 @@ ip6_packet_match(const struct sk_buff *skb,
 	if (FWINV(ret != 0, IP6T_INV_VIA_OUT)) {
 		dprintf("VIA out mismatch (%s vs %s).%s\n",
 			outdev, ip6info->outiface,
-			ip6info->invflags&IP6T_INV_VIA_OUT ?" (INV)":"");
+			ip6info->invflags&IP6T_INV_VIA_OUT ? " (INV)" : "");
 		return false;
 	}
 
-- 
1.9.1

