From: Laura Abbott <labbott@redhat.com>
Subject: [PATCH] drivers: net: phy: Correct duplicate MDIO_XGENE entry
Date: Thu,  6 Oct 2016 11:22:51 -0700
Message-ID: <1475778171-10905-1-git-send-email-labbott@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An extra entry for MDIO_XGENE got added during merging.
Delete it.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/net/phy/Kconfig | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5078a0d..2651c8d 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -142,6 +142,7 @@ config MDIO_THUNDER
 
 config MDIO_XGENE
 	tristate "APM X-Gene SoC MDIO bus controller"
+	depends on ARCH_XGENE || COMPILE_TEST
 	help
 	  This module provides a driver for the MDIO busses found in the
 	  APM X-Gene SoC's.
@@ -320,13 +321,6 @@ config XILINX_GMII2RGMII
          the Reduced Gigabit Media Independent Interface(RGMII) between
          Ethernet physical media devices and the Gigabit Ethernet controller.
 
-config MDIO_XGENE
-	tristate "APM X-Gene SoC MDIO bus controller"
-	depends on ARCH_XGENE || COMPILE_TEST
-	help
-	  This module provides a driver for the MDIO busses found in the
-	  APM X-Gene SoC's.
-
 endif # PHYLIB
 
 config MICREL_KS8995MA
-- 
2.7.4
