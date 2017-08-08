From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: phy: Use tab for indentation in Kconfig
Date: Tue,  8 Aug 2017 11:32:25 +0200
Message-ID: <abacdc7ec0585cfbeba240ca2780c6020cf7090a.1502184742.git.michal.simek@xilinx.com>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using tabs instead of space for indentaion

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/phy/Kconfig | 42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 928fd892f167..5d8cce3fab57 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -5,7 +5,7 @@
 menuconfig MDIO_DEVICE
 	tristate "MDIO bus device drivers"
 	help
-	   MDIO devices and driver infrastructure code.
+	  MDIO devices and driver infrastructure code.
 
 config MDIO_BUS
 	tristate
@@ -107,11 +107,11 @@ config MDIO_HISI_FEMAC
 	  Hisilicon SoC that have an Fast Ethernet MAC.
 
 config MDIO_MOXART
-        tristate "MOXA ART MDIO interface support"
-        depends on ARCH_MOXART
-        help
-          This driver supports the MDIO interface found in the network
-          interface units of the MOXA ART SoC
+	tristate "MOXA ART MDIO interface support"
+	depends on ARCH_MOXART
+	help
+	  This driver supports the MDIO interface found in the network
+	  interface units of the MOXA ART SoC
 
 config MDIO_OCTEON
 	tristate "Octeon and some ThunderX SOCs MDIO buses"
@@ -172,7 +172,7 @@ config LED_TRIGGER_PHY
 	  state change will trigger the events, for consumption by an
 	  LED class driver.  There are triggers for each link speed currently
 	  supported by the phy, and are of the form:
-	       <mii bus id>:<phy>:<speed>
+	      <mii bus id>:<phy>:<speed>
 
 	  Where speed is in the form:
 		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
@@ -186,9 +186,9 @@ config AMD_PHY
 	  Currently supports the am79c874
 
 config AQUANTIA_PHY
-        tristate "Aquantia PHYs"
-        ---help---
-          Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
+	tristate "Aquantia PHYs"
+	---help---
+	  Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
 
 config AT803X_PHY
 	tristate "AT803X PHYs"
@@ -352,21 +352,21 @@ config STE10XP
 	  This is the driver for the STe100p and STe101p PHYs.
 
 config TERANETICS_PHY
-        tristate "Teranetics PHYs"
-        ---help---
-          Currently supports the Teranetics TN2020
+	tristate "Teranetics PHYs"
+	---help---
+	  Currently supports the Teranetics TN2020
 
 config VITESSE_PHY
-        tristate "Vitesse PHYs"
-        ---help---
-          Currently supports the vsc8244
+	tristate "Vitesse PHYs"
+	---help---
+	  Currently supports the vsc8244
 
 config XILINX_GMII2RGMII
-       tristate "Xilinx GMII2RGMII converter driver"
-       ---help---
-         This driver support xilinx GMII to RGMII IP core it provides
-         the Reduced Gigabit Media Independent Interface(RGMII) between
-         Ethernet physical media devices and the Gigabit Ethernet controller.
+	tristate "Xilinx GMII2RGMII converter driver"
+	---help---
+	  This driver support xilinx GMII to RGMII IP core it provides
+	  the Reduced Gigabit Media Independent Interface(RGMII) between
+	  Ethernet physical media devices and the Gigabit Ethernet controller.
 
 endif # PHYLIB
 
-- 
1.9.1
