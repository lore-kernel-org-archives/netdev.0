From: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Subject: [PATCH] net: phy: micrel: KSZ8795 do not set SUPPORTED_[Asym_]Pause
Date: Fri, 27 Jan 2017 21:39:03 +0100
Message-ID: <20170127203903.19171-1-sean.nyekjaer@prevas.dk>
Cc: Sean Nyekjaer <sean.nyekjaer@prevas.dk>, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:20557 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750790AbdA0UjK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 15:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pr commit "net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause"
this phy driver should not set these feature bits.

Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
Fixes: 9d162ed69f51 ("net: phy: micrel: add support for KSZ8795")
---
 drivers/net/phy/micrel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e55809c5beb7..6742070ca676 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -1012,7 +1012,7 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id		= PHY_ID_KSZ8795,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
 	.name		= "Micrel KSZ8795",
-	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
+	.features	= PHY_BASIC_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= kszphy_config_init,
 	.config_aneg	= ksz8873mll_config_aneg,
-- 
2.11.0
