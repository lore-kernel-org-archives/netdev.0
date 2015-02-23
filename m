From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] decnet: Fix obvious o/0 typo
Date: Mon, 23 Feb 2015 12:02:51 +0100
Message-ID: <1424689371-7059-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 net/decnet/dn_route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1d7c1256e845..3b81092771f8 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1062,7 +1062,7 @@ source_ok:
 	if (decnet_debug_level & 16)
 		printk(KERN_DEBUG
 		       "dn_route_output_slow: initial checks complete."
-		       " dst=%o4x src=%04x oif=%d try_hard=%d\n",
+		       " dst=%04x src=%04x oif=%d try_hard=%d\n",
 		       le16_to_cpu(fld.daddr), le16_to_cpu(fld.saddr),
 		       fld.flowidn_oif, try_hard);
 
-- 
2.1.3
