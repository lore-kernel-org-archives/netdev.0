From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/4] net: phy: bcm7xxx: Fix 40nm EPHY features
Date: Sat,  6 Feb 2016 12:58:49 -0800
Message-ID: <1454792331-4435-3-git-send-email-f.fainelli@gmail.com>
References: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33403 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcBFU65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:58:57 -0500
Received: by mail-pf0-f177.google.com with SMTP id w123so88100661pfb.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:58:57 -0800 (PST)
In-Reply-To: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY entries for BCM7425/29/35 declare the 40nm Ethernet PHY as being
10/100/1000 capable, while this is just a 10/100 capable PHY device, fix that.

Fixes: d068b02cfdfc2 ("net: phy: add BCM7425 and BCM7429 PHYs")
Fixes: 9458ceab4917 ("net: phy: bcm7xxx: Add entry for BCM7435")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 234a285..524806d 100644
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
1.7.1
