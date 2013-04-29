From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 4/6] ARM: sunxi: Add EMAC controller node to sun4i DTSI
Date: Mon, 29 Apr 2013 21:36:56 +0200
Message-ID: <1367264218-15235-5-git-send-email-maxime.ripard@free-electrons.com>
References: <1367264218-15235-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Russell King <linux@arm.linux.org.uk>, Emilio Lopez <emilio@elopez.com.ar>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Florian Fainelly <florian@openwrt.org>, Alejandro Mery <amery@geeks.cl>,
 sunny@allwinnertech.com, shuge@allwinnertech.com,
 Maxime Ripard <maxime.ripard@free-electrons.com>, Stefan Roese <sr@denx.de>,
 kevin@allwinnertech.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1367264218-15235-1-git-send-email-maxime.ripard@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
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
1.8.1.2
