From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 5/5] ARM: hackberry: dt: Add Ethernet controller to the Hackberry device tree
Date: Fri, 15 Mar 2013 21:50:04 +0100
Message-ID: <1363380605-6577-6-git-send-email-maxime.ripard@free-electrons.com>
References: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Russell King <linux@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun4i-a10-hackberry.dts |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10-hackberry.dts b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
index f84549a..3808c1a 100644
--- a/arch/arm/boot/dts/sun4i-a10-hackberry.dts
+++ b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
@@ -23,8 +23,27 @@
 	};
 
 	soc {
+		pio: pinctrl@01c20800 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&hackberry_hogs>;
+
+			hackberry_hogs: hogs@0 {
+				allwinner,pins = "PH19";
+				allwinner,function = "gpio_out";
+				allwinner,drive = <0>;
+				allwinner,pull = <0>;
+			};
+		};
+
 		uart0: uart@01c28000 {
 			status = "okay";
 		};
+
+		wemac: ethernet@01c0b000 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&wemac_pins_a>;
+			status = "ok";
+			allwinner,power-gpios = <&pio 7 19 0>;
+		};
 	};
 };
-- 
1.7.10.4
