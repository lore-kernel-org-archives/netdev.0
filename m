From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH net-next v3] net: phy: Use tab for indentation in Kconfig
Date: Mon, 14 Aug 2017 15:43:00 +0200
Message-ID: <fa5773580a36d36e4f7f5765884058af69fb7213.1502718178.git.michal.simek@xilinx.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using tabs instead of space for indentation.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---

Changes in v3:
- Fix commit message s/indentaion/indentation./
  reported-by Andrew Lunn
- Rebase on the top of net-next.
  HEAD commit: f5b589488ea5ed3bb6168b1a4e7f7b95841d8513

Changes in v2:
- Rebased on the top of net-next.
  HEAD commit: 3b2b69efeca734b78bc85fd02253b0465bb2bec7
  Suggested by David Miller

 drivers/net/phy/Kconfig | 42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8c919203291a..5afe6fdcc968 100644
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
@@ -117,11 +117,11 @@ config MDIO_I2C
 	  This is library mode.
 
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
@@ -192,7 +192,7 @@ config LED_TRIGGER_PHY
 	  state change will trigger the events, for consumption by an
 	  LED class driver.  There are triggers for each link speed currently
 	  supported by the phy, and are of the form:
-	       <mii bus id>:<phy>:<speed>
+	      <mii bus id>:<phy>:<speed>
 
 	  Where speed is in the form:
 		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
@@ -211,9 +211,9 @@ config AMD_PHY
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
@@ -382,21 +382,21 @@ config STE10XP
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
