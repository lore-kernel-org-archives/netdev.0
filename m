From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv4 4/6] ARM: sunxi: Add EMAC controller node to sun4i DTSI
Date: Thu, 30 May 2013 15:49:23 +0200
Message-ID: <1369921765-3367-5-git-send-email-maxime.ripard@free-electrons.com>
References: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Tested-by: Richard Genoud <richard.genoud@gmail.com>
---
 arch/arm/boot/dts/sun4i-a10.dtsi | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10.dtsi b/arch/arm/boot/dts/sun4i-a10.dtsi
index ff1f41f..983da33 100644
--- a/arch/arm/boot/dts/sun4i-a10.dtsi
+++ b/arch/arm/boot/dts/sun4i-a10.dtsi
@@ -163,6 +163,22 @@
 		reg = <0x01c20000 0x300000>;
 		ranges;
 
+		emac: ethernet@01c0b000 {
+			compatible = "allwinner,sun4i-emac";
+			reg = <0x01c0b000 0x1000>;
+			interrupts = <55>;
+			clocks = <&ahb_gates 17>;
+			status = "disabled";
+		};
+
+		mdio@01c0b080 {
+			compatible = "allwinner,sun4i-mdio";
+			reg = <0x01c0b080 0x14>;
+			status = "disabled";
+			#address-cells = <1>;
+			#size-cells = <0>;
+		};
+
 		intc: interrupt-controller@01c20400 {
 			compatible = "allwinner,sun4i-ic";
 			reg = <0x01c20400 0x400>;
-- 
1.8.2.3
