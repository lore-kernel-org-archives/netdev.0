From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/2] documentation: dt: bindings: cpsw: fixing the examples for directly using it in dts file
Date: Mon, 6 Aug 2012 20:35:58 +0530
Message-ID: <1344265558-5724-3-git-send-email-mugunthanvnm@ti.com>
References: <1344265558-5724-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1344265558-5724-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixing the cpsw device tree example to make it simpler to copy pastable to dts
file and use it directly.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |  101 ++++++++++++-----------
 1 files changed, 53 insertions(+), 48 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index acca48c..dcaabe9 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -11,6 +11,7 @@ Required properties:
 - cpdma_channels 	: Specifies number of channels in CPDMA
 - host_port_no		: Specifies host port shift
 - cpdma_reg_ofs		: Specifies CPDMA submodule register offset
+- cpdma_sram_ofs	: Specifies CPDMA SRAM offset
 - ale_reg_ofs		: Specifies ALE submodule register offset
 - ale_entries		: Specifies No of entries ALE can hold
 - host_port_reg_ofs	: Specifies host port register offset
@@ -43,62 +44,66 @@ Examples:
 		reg = <0x4A100000 0x1000>;
 		interrupts = <55 0x4>;
 		interrupt-parent = <&intc>;
-		cpdma_channels = 8;
-		host_port_no = 0;
-		cpdma_reg_ofs = 0x800;
-		ale_reg_ofs = 0xd00;
-		ale_entries = 1024;
-		host_port_reg_ofs = 0x108;
-		hw_stats_reg_ofs = 0x900;
-		bd_ram_ofs = 0x2000;
-		bd_ram_size = 0x2000;
-		no_bd_ram = 0;
-		rx_descs = 64;
-		mac_control = 0x20;
-		slaves = 2;
-		slave@0 {
-			slave_reg_ofs = 0x208;
-			sliver_reg_ofs = 0xd80;
-			phy_id = "davinci_mdio-0:00"
-			mac-address = [00 04 9F 01 1B B8];
+		cpdma_channels = <8>;
+		host_port_no = <0>;
+		cpdma_reg_ofs = <0x800>;
+		cpdma_sram_ofs = <0xa00>;
+		ale_reg_ofs = <0xd00>;
+		ale_entries = <1024>;
+		host_port_reg_ofs = <0x108>;
+		hw_stats_reg_ofs = <0x900>;
+		bd_ram_ofs = <0x2000>;
+		bd_ram_size = <0x2000>;
+		no_bd_ram = <0>;
+		rx_descs = <64>;
+		mac_control = <0x20>;
+		slaves = <2>;
+		cpsw_emac0: slave@0 {
+			slave_reg_ofs = <0x208>;
+			sliver_reg_ofs = <0xd80>;
+			phy_id = "davinci_mdio.16:00";
+			/* Filled in by U-Boot */
+			mac-address = [ 00 00 00 00 00 00 ];
 		};
-		slave@1 {
-			slave_reg_ofs = 0x208;
-			sliver_reg_ofs = 0xd80;
-			phy_id = "davinci_mdio-0:01"
-			mac-address = [00 04 9F 01 1B B9];
+		cpsw_emac1: slave@1 {
+			slave_reg_ofs = <0x308>;
+			sliver_reg_ofs = <0xdc0>;
+			phy_id = "davinci_mdio.16:01";
+			/* Filled in by U-Boot */
+			mac-address = [ 00 00 00 00 00 00 ];
 		};
 	};
 
 (or)
-
 	mac: ethernet@4A100000 {
 		compatible = "ti,cpsw";
 		ti,hwmods = "cpgmac0";
-		cpdma_channels = 8;
-		host_port_no = 0;
-		cpdma_reg_ofs = 0x800;
-		ale_reg_ofs = 0xd00;
-		ale_entries = 1024;
-		host_port_reg_ofs = 0x108;
-		hw_stats_reg_ofs = 0x900;
-		bd_ram_ofs = 0x2000;
-		bd_ram_size = 0x2000;
-		no_bd_ram = 0;
-		rx_descs = 64;
-		mac_control = 0x20;
-		slaves = 2;
-		slave@0 {
-			slave_reg_ofs = 0x208;
-			sliver_reg_ofs = 0xd80;
-			phy_id = "davinci_mdio-0:00"
-			mac-address = [00 04 9F 01 1B B8];
+		cpdma_channels = <8>;
+		host_port_no = <0>;
+		cpdma_reg_ofs = <0x800>;
+		cpdma_sram_ofs = <0xa00>;
+		ale_reg_ofs = <0xd00>;
+		ale_entries = <1024>;
+		host_port_reg_ofs = <0x108>;
+		hw_stats_reg_ofs = <0x900>;
+		bd_ram_ofs = <0x2000>;
+		bd_ram_size = <0x2000>;
+		no_bd_ram = <0>;
+		rx_descs = <64>;
+		mac_control = <0x20>;
+		slaves = <2>;
+		cpsw_emac0: slave@0 {
+			slave_reg_ofs = <0x208>;
+			sliver_reg_ofs = <0xd80>;
+			phy_id = "davinci_mdio.16:00";
+			/* Filled in by U-Boot */
+			mac-address = [ 00 00 00 00 00 00 ];
 		};
-		slave@1 {
-			slave_reg_ofs = 0x208;
-			sliver_reg_ofs = 0xd80;
-			phy_id = "davinci_mdio-0:01"
-			mac-address = [00 04 9F 01 1B B9];
+		cpsw_emac1: slave@1 {
+			slave_reg_ofs = <0x308>;
+			sliver_reg_ofs = <0xdc0>;
+			phy_id = "davinci_mdio.16:01";
+			/* Filled in by U-Boot */
+			mac-address = [ 00 00 00 00 00 00 ];
 		};
-
 	};
-- 
1.7.0.4

