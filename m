From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/4] net: phy: bcm7xxx: Fix 40nm EPHY features
Date: Wed,  3 Feb 2016 13:13:47 -0800
Message-ID: <1454534029-585-3-git-send-email-f.fainelli@gmail.com>
References: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33343 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933883AbcBCVPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:15:52 -0500
Received: by mail-pf0-f170.google.com with SMTP id w123so20154598pfb.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:15:52 -0800 (PST)
In-Reply-To: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY entries for BCM7425/29/35 declare the 40nm Ethernet PHY as being
10/100/1000 capable, while this is just a 10/100 capable PHY device, fix that.

Fixes: d068b02cfdfc2 ("net: phy: add BCM7425 and BCM7429 PHYs")
Fixes: 9458ceab4917 ("net: phy: bcm7xxx: Add entry for BCM7435")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 234a28502793..524806dd0f6b 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -337,7 +337,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.phy_id         = PHY_ID_BCM7425,
 	.phy_id_mask    = 0xfffffff0,
 	.name           = "Broadcom BCM7425",
-	.features       = PHY_GBIT_FEATURES |
+	.features       = PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_IS_INTERNAL,
 	.config_init    = bcm7xxx_config_init,
@@ -349,7 +349,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.phy_id         = PHY_ID_BCM7429,
 	.phy_id_mask    = 0xfffffff0,
 	.name           = "Broadcom BCM7429",
-	.features       = PHY_GBIT_FEATURES |
+	.features       = PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_IS_INTERNAL,
 	.config_init    = bcm7xxx_config_init,
@@ -361,7 +361,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	.phy_id         = PHY_ID_BCM7435,
 	.phy_id_mask    = 0xfffffff0,
 	.name           = "Broadcom BCM7435",
-	.features       = PHY_GBIT_FEATURES |
+	.features       = PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_IS_INTERNAL,
 	.config_init    = bcm7xxx_config_init,
-- 
2.1.0
