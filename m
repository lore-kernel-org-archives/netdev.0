From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 8/8] ARM: dts: AM33XX: Add phy-mode to CPSW node
Date: Tue, 4 Jun 2013 11:40:11 +0530
Message-ID: <1370326212-17580-9-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding phy-mode to CPSW node for beaglebone, EVM and EVMsk.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-bone.dts  |    2 ++
 arch/arm/boot/dts/am335x-evm.dts   |    2 ++
 arch/arm/boot/dts/am335x-evmsk.dts |    2 ++
 3 files changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-bone.dts b/arch/arm/boot/dts/am335x-bone.dts
index 5302f79..4b5a8e0 100644
--- a/arch/arm/boot/dts/am335x-bone.dts
+++ b/arch/arm/boot/dts/am335x-bone.dts
@@ -131,8 +131,10 @@
 
 &cpsw_emac0 {
 	phy_id = <&davinci_mdio>, <0>;
+	phy-mode = "mii";
 };
 
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
+	phy-mode = "mii";
 };
diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 0423298..814ee03 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -239,8 +239,10 @@
 
 &cpsw_emac0 {
 	phy_id = <&davinci_mdio>, <0>;
+	phy-mode = "rgmii-txid";
 };
 
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
+	phy-mode = "rgmii-txid";
 };
diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index acbcac3..4297899 100644
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@ -251,8 +251,10 @@
 
 &cpsw_emac0 {
 	phy_id = <&davinci_mdio>, <0>;
+	phy-mode = "rgmii-txid";
 };
 
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
+	phy-mode = "rgmii-txid";
 };
-- 
1.7.9.5

