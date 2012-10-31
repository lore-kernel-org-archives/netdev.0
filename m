From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 2/4] ARM: dts: imx6q: Add ENET PTP clock pin and clock source
Date: Wed, 31 Oct 2012 12:24:57 +0800
Message-ID: <1351657497-24923-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznua@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:37383
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751271Ab2JaFIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 01:08:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ENET 1588 clock input pin
MX6Q_PAD_GPIO_16__ENET_ANATOP_ETHERNET_REF_OUT
and anatop PLL8 clock source for ENET

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 arch/arm/boot/dts/imx6q.dtsi |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/imx6q.dtsi b/arch/arm/boot/dts/imx6q.dtsi
index f3990b0..3290e61 100644
--- a/arch/arm/boot/dts/imx6q.dtsi
+++ b/arch/arm/boot/dts/imx6q.dtsi
@@ -580,6 +580,7 @@
 							66  0x1b0b0	/* MX6Q_PAD_RGMII_RD2__ENET_RGMII_RD2 */
 							70  0x1b0b0	/* MX6Q_PAD_RGMII_RD3__ENET_RGMII_RD3 */
 							48  0x1b0b0	/* MX6Q_PAD_RGMII_RX_CTL__RGMII_RX_CTL */
+							1033 0x4001b0a8	/* MX6Q_PAD_GPIO_16__ENET_ANATOP_ETHERNET_REF_OUT*/
 						>;
 					};
 
@@ -833,8 +834,8 @@
 				compatible = "fsl,imx6q-fec";
 				reg = <0x02188000 0x4000>;
 				interrupts = <0 118 0x04 0 119 0x04>;
-				clocks = <&clks 117>, <&clks 117>;
-				clock-names = "ipg", "ahb";
+				clocks = <&clks 117>, <&clks 117>, <&clks 177>;
+				clock-names = "ipg", "ahb", "ptp";
 				status = "disabled";
 			};
 
-- 
1.7.1
