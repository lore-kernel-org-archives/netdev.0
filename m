From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH] drivers: net: sun4i-emac: select MDIO_SUN4I
Date: Wed, 24 Jul 2013 09:12:08 +0200
Message-ID: <1374649928-26007-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The EMAC driver can't work without its associated PHY driver. Reflect
this in the Kconfig options by selecting it.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/allwinner/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
index cf7aa24..d8d95d4 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -27,6 +27,7 @@ config SUN4I_EMAC
 	select CRC32
 	select MII
 	select PHYLIB
+	select MDIO_SUN4I
         ---help---
           Support for Allwinner A10 EMAC ethernet driver.
 
-- 
1.8.3.2
