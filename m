From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH RESEND v6 7/7] arm: dts: am33xx, Add syscon phandle to cpsw node
Date: Mon, 29 Sep 2014 08:53:19 +0200
Message-ID: <1411973599-18908-8-git-send-email-mpa@pengutronix.de>
References: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Cc: =?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson@baylibre.com>,
	Tony Lindgren <tony@atomide.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Markus Pargmann <mpa@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1411973599-18908-1-git-send-email-mpa@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are 2 MACIDs stored in the control module of the am33xx. These are
read by the cpsw driver if no valid MACID was found in the devicetree.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Reviewed-by: Wolfram Sang <wsa@the-dreams.de>
Acked-by: Tony Lindgren <tony@atomide.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 25e38b6ac376..13e44b0f5adc 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -701,6 +701,7 @@
 			 */
 			interrupts = <40 41 42 43>;
 			ranges;
+			syscon = <&cm>;
 			status = "disabled";
 
 			davinci_mdio: mdio@4a101000 {
-- 
2.1.0

