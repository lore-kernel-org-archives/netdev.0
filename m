From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: Remove invalid CR write during ZD1211 phy reset
Date: Tue,  3 Apr 2007 23:03:55 +0100 (BST)
Message-ID: <20070403220355.CDF7C7B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:56278 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751955AbXDCWDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 18:03:51 -0400
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vendor driver only does the CR123 write for non-USB devices (which
don't exist on the consumer market)

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index 05624b3..53bbd34 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -684,17 +684,17 @@ static int zd1211_hw_reset_phy(struct zd_chip *chip)
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
-- 
1.5.0.6

