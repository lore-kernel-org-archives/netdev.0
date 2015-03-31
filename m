From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] ARM: at91/dt: sama5d3 xplained: add phy address for macb0
Date: Tue, 31 Mar 2015 11:01:12 +0200
Message-ID: <1427792472-13555-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<f.fainelli@gmail.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Specify the phy address on macb0 node aka GEM.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 arch/arm/boot/dts/at91-sama5d3_xplained.dts | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/boot/dts/at91-sama5d3_xplained.dts b/arch/arm/boot/dts/at91-sama5d3_xplained.dts
index 6c4bc53cbf4e..08cb500ce171 100644
--- a/arch/arm/boot/dts/at91-sama5d3_xplained.dts
+++ b/arch/arm/boot/dts/at91-sama5d3_xplained.dts
@@ -105,7 +105,13 @@
 
 			macb0: ethernet@f0028000 {
 				phy-mode = "rgmii";
+				#address-cells = <1>;
+				#size-cells = <0>;
 				status = "okay";
+
+				ethernet-phy@7 {
+					reg = <0x7>;
+				};
 			};
 
 			pwm0: pwm@f002c000 {
-- 
2.1.3
