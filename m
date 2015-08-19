From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 5/6] ARM: dts: imx7d: add fec1 and fec2 support for i.MX7d soc
Date: Wed, 19 Aug 2015 13:34:03 +0800
Message-ID: <1439962444-27486-6-git-send-email-b38611@freescale.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<b38611@freescale.com>
To: <shawnguo@kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0141.outbound.protection.outlook.com ([157.56.110.141]:50976
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751426AbbHSFen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 01:34:43 -0400
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add fec1 and fec2 nodes for i.MX7d soc.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx7d.dtsi | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/imx7d.dtsi b/arch/arm/boot/dts/imx7d.dtsi
index b738ce0..7631492 100644
--- a/arch/arm/boot/dts/imx7d.dtsi
+++ b/arch/arm/boot/dts/imx7d.dtsi
@@ -729,6 +729,42 @@
 				bus-width = <4>;
 				status = "disabled";
 			};
+
+			fec1: ethernet@30be0000 {
+				compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
+				reg = <0x30be0000 0x10000>;
+				interrupts = <GIC_SPI 118 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 119 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 120 IRQ_TYPE_LEVEL_HIGH>;
+				clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
+					<&clks IMX7D_ENET_AXI_ROOT_CLK>,
+					<&clks IMX7D_ENET1_TIME_ROOT_CLK>,
+					<&clks IMX7D_PLL_ENET_MAIN_125M_CLK>,
+					<&clks IMX7D_ENET_PHY_REF_ROOT_CLK>;
+				clock-names = "ipg", "ahb", "ptp",
+					"enet_clk_ref", "enet_out";
+				fsl,num-tx-queues=<3>;
+				fsl,num-rx-queues=<3>;
+				status = "disabled";
+			};
+
+			fec2: ethernet@30bf0000 {
+				compatible = "fsl,imx7d-fec", "fsl,imx6sx-fec";
+				reg = <0x30bf0000 0x10000>;
+				interrupts = <GIC_SPI 100 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 101 IRQ_TYPE_LEVEL_HIGH>,
+					<GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>;
+				clocks = <&clks IMX7D_ENET_AXI_ROOT_CLK>,
+					<&clks IMX7D_ENET_AXI_ROOT_CLK>,
+					<&clks IMX7D_ENET2_TIME_ROOT_CLK>,
+					<&clks IMX7D_PLL_ENET_MAIN_125M_CLK>,
+					<&clks IMX7D_ENET_PHY_REF_ROOT_CLK>;
+				clock-names = "ipg", "ahb", "ptp",
+					"enet_clk_ref", "enet_out";
+				fsl,num-tx-queues=<3>;
+				fsl,num-rx-queues=<3>;
+				status = "disabled";
+			};
 		};
 	};
 };
-- 
1.9.1
