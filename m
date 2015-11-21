From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [PATCH] broadcom: fix PHY_ID_BCM5481 entry in the id table
Date: Sun, 22 Nov 2015 01:08:54 +0200
Message-ID: <1448147334-10518-1-git-send-email-aaro.koskinen@iki.fi>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh07.mail.saunalahti.fi ([62.142.5.117]:38300 "EHLO
	emh07.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbKUXRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 18:17:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fcb26ec5b18d ("broadcom: move all PHY_ID's to header")
updated broadcom_tbl to use PHY_IDs, but incorrectly replaced 0x0143bca0
with PHY_ID_BCM5482 (making a duplicate entry, and completely omitting
the original). Fix that.

Fixes: fcb26ec5b18d ("broadcom: move all PHY_ID's to header")
Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
---
 drivers/net/phy/broadcom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 07a6119..3ce5d95 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -614,7 +614,7 @@ static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM5461, 0xfffffff0 },
 	{ PHY_ID_BCM54616S, 0xfffffff0 },
 	{ PHY_ID_BCM5464, 0xfffffff0 },
-	{ PHY_ID_BCM5482, 0xfffffff0 },
+	{ PHY_ID_BCM5481, 0xfffffff0 },
 	{ PHY_ID_BCM5482, 0xfffffff0 },
 	{ PHY_ID_BCM50610, 0xfffffff0 },
 	{ PHY_ID_BCM50610M, 0xfffffff0 },
-- 
2.4.0
