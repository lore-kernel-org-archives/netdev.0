From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: phy: Kconfig: Remove redundant "Support for"
Date: Thu, 18 Aug 2016 23:56:06 +0200
Message-ID: <1471557366-21672-3-git-send-email-andrew@lunn.ch>
References: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38657 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754020AbcHSBzI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:08 -0400
In-Reply-To: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the redundant "Support for" and "Drivers for" from the Kconfig
short description. This makes the manufacture much more prominent in
the list and makes the shortcut keys useful.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/Kconfig | 70 ++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 786e8b0b2d06..1c3e07c3d0b8 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -35,7 +35,7 @@ config MDIO_BCM_UNIMAC
 	  Starfighter 2 switches.
 
 config MDIO_BITBANG
-	tristate "Support for bitbanged MDIO buses"
+	tristate "Bitbanged MDIO buses"
 	help
 	  This module implements the MDIO bus protocol in software,
 	  for use by low level drivers that export the ability to
@@ -53,7 +53,7 @@ config MDIO_BUS_MUX
 	  device specific drivers.
 
 config MDIO_BUS_MUX_BCM_IPROC
-	tristate "Support for iProc based MDIO bus multiplexers"
+	tristate "Broadcom iProc based MDIO bus multiplexers"
 	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
 	select MDIO_BUS_MUX
 	default ARCH_BCM_IPROC
@@ -64,7 +64,7 @@ config MDIO_BUS_MUX_BCM_IPROC
 	  external and selection logic lies inside the same multiplexer.
 
 config MDIO_BUS_MUX_GPIO
-	tristate "Support for GPIO controlled MDIO bus multiplexers"
+	tristate "GPIO controlled MDIO bus multiplexers"
 	depends on OF_GPIO && OF_MDIO
 	select MDIO_BUS_MUX
 	help
@@ -74,7 +74,7 @@ config MDIO_BUS_MUX_GPIO
 	  selection is under the control of GPIO lines.
 
 config MDIO_BUS_MUX_MMIOREG
-	tristate "Support for MMIO device-controlled MDIO bus multiplexers"
+	tristate "MMIO device-controlled MDIO bus multiplexers"
 	depends on OF_MDIO && HAS_IOMEM
 	select MDIO_BUS_MUX
 	help
@@ -90,7 +90,7 @@ config MDIO_CAVIUM
 	tristate
 
 config MDIO_GPIO
-	tristate "Support for GPIO lib-based bitbanged MDIO buses"
+	tristate "GPIO lib-based bitbanged MDIO buses"
 	depends on MDIO_BITBANG && GPIOLIB
 	---help---
 	  Supports GPIO lib-based MDIO busses.
@@ -113,7 +113,7 @@ config MDIO_MOXART
           interface units of the MOXA ART SoC
 
 config MDIO_OCTEON
-	tristate "Support for MDIO buses on Octeon and some ThunderX SOCs"
+	tristate "Octeon and some ThunderX SOCs MDIO buses"
 	depends on 64BIT
 	depends on HAS_IOMEM
 	select MDIO_CAVIUM
@@ -131,7 +131,7 @@ config MDIO_SUN4I
 	  A12, A10s, etc.)
 
 config MDIO_THUNDER
-	tristate "Support for MDIO buses on ThunderX SOCs"
+	tristate "ThunderX SOCs MDIO buses"
 	depends on 64BIT
 	depends on PCI
 	select MDIO_CAVIUM
@@ -149,41 +149,41 @@ config MDIO_XGENE
 comment "MII PHY device drivers"
 
 config AMD_PHY
-	tristate "Drivers for the AMD PHYs"
+	tristate "AMD PHYs"
 	---help---
 	  Currently supports the am79c874
 
 config AQUANTIA_PHY
-        tristate "Drivers for the Aquantia PHYs"
+        tristate "Aquantia PHYs"
         ---help---
           Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
 
 config AT803X_PHY
-	tristate "Drivers for Atheros AT803X PHYs"
+	tristate "AT803X PHYs"
 	---help---
 	  Currently supports the AT8030 and AT8035 model
 
 config BCM63XX_PHY
-	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
+	tristate "Broadcom 63xx SOCs internal PHY"
 	depends on BCM63XX
 	select BCM_NET_PHYLIB
 	---help---
 	  Currently supports the 6348 and 6358 PHYs.
 
 config BCM7XXX_PHY
-	tristate "Drivers for Broadcom 7xxx SOCs internal PHYs"
+	tristate "Broadcom 7xxx SOCs internal PHYs"
 	select BCM_NET_PHYLIB
 	---help---
 	  Currently supports the BCM7366, BCM7439, BCM7445, and
 	  40nm and 65nm generation of BCM7xxx Set Top Box SoCs.
 
 config BCM87XX_PHY
-	tristate "Driver for Broadcom BCM8706 and BCM8727 PHYs"
+	tristate "Broadcom BCM8706 and BCM8727 PHYs"
 	help
 	  Currently supports the BCM8706 and BCM8727 10G Ethernet PHYs.
 
 config BCM_CYGNUS_PHY
-	tristate "Drivers for Broadcom Cygnus SoC internal PHY"
+	tristate "Broadcom Cygnus SoC internal PHY"
 	depends on ARCH_BCM_CYGNUS || COMPILE_TEST
 	depends on MDIO_BCM_IPROC
 	select BCM_NET_PHYLIB
@@ -199,34 +199,34 @@ config BCM_NET_PHYLIB
 	tristate
 
 config BROADCOM_PHY
-	tristate "Drivers for Broadcom PHYs"
+	tristate "Broadcom PHYs"
 	select BCM_NET_PHYLIB
 	---help---
 	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
 	  BCM5481 and BCM5482 PHYs.
 
 config CICADA_PHY
-	tristate "Drivers for the Cicada PHYs"
+	tristate "Cicada PHYs"
 	---help---
 	  Currently supports the cis8204
 
 config DAVICOM_PHY
-	tristate "Drivers for Davicom PHYs"
+	tristate "Davicom PHYs"
 	---help---
 	  Currently supports dm9161e and dm9131
 
 config DP83848_PHY
-	tristate "Driver for Texas Instruments DP83848 PHY"
+	tristate "Texas Instruments DP83848 PHY"
 	---help---
 	  Supports the DP83848 PHY.
 
 config DP83867_PHY
-	tristate "Drivers for Texas Instruments DP83867 Gigabit PHY"
+	tristate "Texas Instruments DP83867 Gigabit PHY"
 	---help---
 	  Currently supports the DP83867 PHY.
 
 config FIXED_PHY
-	tristate "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
+	tristate "MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB
 	select SWPHY
 	---help---
@@ -236,12 +236,12 @@ config FIXED_PHY
 	  Currently tested with mpc866ads and mpc8349e-mitx.
 
 config ICPLUS_PHY
-	tristate "Drivers for ICPlus PHYs"
+	tristate "ICPlus PHYs"
 	---help---
 	  Currently supports the IP175C and IP1001 PHYs.
 
 config INTEL_XWAY_PHY
-	tristate "Driver for Intel XWAY PHYs"
+	tristate "Intel XWAY PHYs"
 	---help---
 	  Supports the Intel XWAY (former Lantiq) 11G and 22E PHYs.
 	  These PHYs are marked as standalone chips under the names
@@ -249,67 +249,67 @@ config INTEL_XWAY_PHY
 	  SoCs xRX200, xRX300, xRX330, xRX350 and xRX550.
 
 config LSI_ET1011C_PHY
-	tristate "Driver for LSI ET1011C PHY"
+	tristate "LSI ET1011C PHY"
 	---help---
 	  Supports the LSI ET1011C PHY.
 
 config LXT_PHY
-	tristate "Drivers for the Intel LXT PHYs"
+	tristate "Intel LXT PHYs"
 	---help---
 	  Currently supports the lxt970, lxt971
 
 config MARVELL_PHY
-	tristate "Drivers for Marvell PHYs"
+	tristate "Marvell PHYs"
 	---help---
 	  Currently has a driver for the 88E1011S
 
 config MICREL_PHY
-	tristate "Driver for Micrel PHYs"
+	tristate "Micrel PHYs"
 	---help---
 	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
 
 config MICROCHIP_PHY
-	tristate "Drivers for Microchip PHYs"
+	tristate "Microchip PHYs"
 	help
 	  Supports the LAN88XX PHYs.
 
 config MICROSEMI_PHY
-    tristate "Drivers for the Microsemi PHYs"
+    tristate "Microsemi PHYs"
     ---help---
       Currently supports the VSC8531 and VSC8541 PHYs
 
 config NATIONAL_PHY
-	tristate "Drivers for National Semiconductor PHYs"
+	tristate "National Semiconductor PHYs"
 	---help---
 	  Currently supports the DP83865 PHY.
 
 config QSEMI_PHY
-	tristate "Drivers for Quality Semiconductor PHYs"
+	tristate "Quality Semiconductor PHYs"
 	---help---
 	  Currently supports the qs6612
 
 config REALTEK_PHY
-	tristate "Drivers for Realtek PHYs"
+	tristate "Realtek PHYs"
 	---help---
 	  Supports the Realtek 821x PHY.
 
 config SMSC_PHY
-	tristate "Drivers for SMSC PHYs"
+	tristate "SMSC PHYs"
 	---help---
 	  Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
 
 config STE10XP
-	tristate "Driver for STMicroelectronics STe10Xp PHYs"
+	tristate "STMicroelectronics STe10Xp PHYs"
 	---help---
 	  This is the driver for the STe100p and STe101p PHYs.
 
 config TERANETICS_PHY
-        tristate "Drivers for the Teranetics PHYs"
+        tristate "Teranetics PHYs"
         ---help---
           Currently supports the Teranetics TN2020
 
 config VITESSE_PHY
-        tristate "Drivers for the Vitesse PHYs"
+        tristate "Vitesse PHYs"
         ---help---
           Currently supports the vsc8244
 
-- 
2.8.1
