From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH RESEND v6 1/7] DT doc: net: cpsw mac-address is optional
Date: Mon, 29 Sep 2014 08:53:13 +0200
Message-ID: <1411973599-18908-2-git-send-email-mpa@pengutronix.de>
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

mac-address is an optional property. If no mac-address is set, a random
mac-address will be generated.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Reviewed-by: Wolfram Sang <wsa@the-dreams.de>
---
 Documentation/devicetree/bindings/net/cpsw.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index ae2b8b7f9c38..107caf174a0e 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -29,10 +29,10 @@ Slave Properties:
 Required properties:
 - phy_id		: Specifies slave phy id
 - phy-mode		: See ethernet.txt file in the same directory
-- mac-address		: See ethernet.txt file in the same directory
 
 Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
+- mac-address		: See ethernet.txt file in the same directory
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
-- 
2.1.0

