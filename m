From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 4/5] ARM: cubieboard: Enable ethernet (WEMAC) support in dts
Date: Sat, 23 Mar 2013 23:30:13 +0100
Message-ID: <1364077814-2233-5-git-send-email-maxime.ripard@free-electrons.com>
References: <1364077814-2233-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Stefan Roese <sr@denx.de>, Alejandro Mery <amery@geeks.cl>,
	Russell King <linux@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364077814-2233-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Roese <sr@denx.de>

Signed-off-by: Stefan Roese <sr@denx.de>
---
 arch/arm/boot/dts/sun4i-a10-cubieboard.dts |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10-cubieboard.dts b/arch/arm/boot/dts/sun4i-a10-cubieboard.dts
index 88e2dc1..9bf4b4f 100644
--- a/arch/arm/boot/dts/sun4i-a10-cubieboard.dts
+++ b/arch/arm/boot/dts/sun4i-a10-cubieboard.dts
@@ -43,6 +43,12 @@
 		uart1: uart@01c28400 {
 			status = "okay";
 		};
+
+		emac: ethernet@01c0b000 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&emac_pins_a>;
+			status = "okay";
+		};
 	};
 
 	leds {
-- 
1.7.10.4
