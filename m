From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH RESEND v6 6/7] am33xx: define syscon control module device node
Date: Mon, 29 Sep 2014 08:53:18 +0200
Message-ID: <1411973599-18908-7-git-send-email-mpa@pengutronix.de>
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

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Reviewed-by: Wolfram Sang <wsa@the-dreams.de>
Acked-by: Tony Lindgren <tony@atomide.com>
---
 arch/arm/boot/dts/am33xx.dtsi | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 3a0a161342ba..25e38b6ac376 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -132,6 +132,11 @@
 			};
 		};
 
+		cm: syscon@44e10000 {
+			compatible = "ti,am33xx-controlmodule", "syscon";
+			reg = <0x44e10000 0x800>;
+		};
+
 		intc: interrupt-controller@48200000 {
 			compatible = "ti,omap2-intc";
 			interrupt-controller;
-- 
2.1.0

