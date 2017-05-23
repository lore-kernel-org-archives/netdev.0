From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: phy: put genphy_config_init's EXPORT_SYMBOL directly after the function
Date: Wed, 24 May 2017 00:26:07 +0200
Message-ID: <20170523222607.13645-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33599 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1034988AbdEWW00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 18:26:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit af6b6967d6e1 ("net: phy: export genphy_config_init()") introduced
this EXPORT_SYMBOL and put it after gen10g_soft_reset() instead of
directly after genphy_config_init. Probably this happend when the patch
was applied because http://patchwork.ozlabs.org/patch/339622/ looks ok.

Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1219eeab69d1..0780e9f9e167 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1571,13 +1571,13 @@ int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+EXPORT_SYMBOL(genphy_config_init);
 
 static int gen10g_soft_reset(struct phy_device *phydev)
 {
 	/* Do nothing for now */
 	return 0;
 }
-EXPORT_SYMBOL(genphy_config_init);
 
 static int gen10g_config_init(struct phy_device *phydev)
 {
-- 
2.11.0
