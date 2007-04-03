From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Remove invalid CR write during ZD1211 phy reset
Date: Tue,  3 Apr 2007 23:17:10 +0100 (BST)
Message-ID: <20070403221710.89FD07B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The vendor driver only does the CR123 write for non-USB devices (which
don't exist on the consumer market)

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_chip.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -684,17 +684,17 @@ static int zd1211_hw_reset_phy(struct zd
 		{ CR111, 0x27 }, { CR112, 0x27 }, { CR113, 0x27 },
 		{ CR114, 0x27 }, { CR115, 0x26 }, { CR116, 0x24 },
 		{ CR117, 0xfc }, { CR118, 0xfa }, { CR120, 0x4f },
-		{ CR123, 0x27 }, { CR125, 0xaa }, { CR127, 0x03 },
-		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
-		{ CR131, 0x0C }, { CR136, 0xdf }, { CR137, 0x40 },
-		{ CR138, 0xa0 }, { CR139, 0xb0 }, { CR140, 0x99 },
-		{ CR141, 0x82 }, { CR142, 0x54 }, { CR143, 0x1c },
-		{ CR144, 0x6c }, { CR147, 0x07 }, { CR148, 0x4c },
-		{ CR149, 0x50 }, { CR150, 0x0e }, { CR151, 0x18 },
-		{ CR160, 0xfe }, { CR161, 0xee }, { CR162, 0xaa },
-		{ CR163, 0xfa }, { CR164, 0xfa }, { CR165, 0xea },
-		{ CR166, 0xbe }, { CR167, 0xbe }, { CR168, 0x6a },
-		{ CR169, 0xba }, { CR170, 0xba }, { CR171, 0xba },
+		{ CR125, 0xaa }, { CR127, 0x03 }, { CR128, 0x14 },
+		{ CR129, 0x12 }, { CR130, 0x10 }, { CR131, 0x0C },
+		{ CR136, 0xdf }, { CR137, 0x40 }, { CR138, 0xa0 },
+		{ CR139, 0xb0 }, { CR140, 0x99 }, { CR141, 0x82 },
+		{ CR142, 0x54 }, { CR143, 0x1c }, { CR144, 0x6c },
+		{ CR147, 0x07 }, { CR148, 0x4c }, { CR149, 0x50 },
+		{ CR150, 0x0e }, { CR151, 0x18 }, { CR160, 0xfe },
+		{ CR161, 0xee }, { CR162, 0xaa }, { CR163, 0xfa },
+		{ CR164, 0xfa }, { CR165, 0xea }, { CR166, 0xbe },
+		{ CR167, 0xbe }, { CR168, 0x6a }, { CR169, 0xba },
+		{ CR170, 0xba }, { CR171, 0xba },
 		/* Note: CR204 must lead the CR203 */
 		{ CR204, 0x7d },
 		{ },
