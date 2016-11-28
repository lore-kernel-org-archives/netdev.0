From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Mon, 28 Nov 2016 15:19:27 +0530
Message-ID: <1480326567-6132-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <harinik@xilinx.com>,
        <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
        <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>,
        <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add documentations for macb mdio driver.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 .../devicetree/bindings/net/macb-mdio.txt          | 31 ++++++++++++++++++++++
 1 file changed, 31 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/macb-mdio.txt

diff --git a/Documentation/devicetree/bindings/net/macb-mdio.txt b/Documentation/devicetree/bindings/net/macb-mdio.txt
new file mode 100644
index 0000000..014cedf
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/macb-mdio.txt
@@ -0,0 +1,31 @@
+* Cadence MACB MDIO controller
+
+Required properties:
+- compatible: Should be "cdns,macb-mdio"
+- reg: Address and length of the register set of MAC to be used
+- clock-names: Tuple listing input clock names.
+	Required elements: 'pclk', 'hclk'
+	Optional elements: 'tx_clk'
+- clocks: Phandles to input clocks.
+
+Examples:
+
+	mdio {
+		compatible = "cdns,macb-mdio";
+		reg = <0x0 0xff0b0000 0x0 0x1000>;
+		clocks = <&clk125>, <&clk125>, <&clk125>;
+		clock-names = "pclk", "hclk", "tx_clk";
+		ethernet_phyC: ethernet-phy@C {
+			reg = <0xC>;
+		};
+		ethernet_phy7: ethernet-phy@7 {
+			reg = <0x7>;
+		};
+		ethernet_phy3: ethernet-phy@3 {
+			reg = <0x3>;
+		};
+		ethernet_phy8: ethernet-phy@8 {
+			reg = <0x8>;
+		};
+	};
+
-- 
2.7.4
