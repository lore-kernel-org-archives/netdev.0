From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 4/4] net/macb: add config for Atmel sama5d2 SoCs
Date: Thu, 18 Jun 2015 16:27:23 +0200
Message-ID: <b5d2868d4e35e29fb96d672177fa49448946e055.1434637286.git.nicolas.ferre@atmel.com>
References: <cover.1434637286.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1434637286.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>

Add the compatible string for Atmel sama5d2 SoC family as the configuration
options differ from other instances of the GEM.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 740d04fd2223..caeb39561567 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2713,6 +2713,13 @@ static const struct macb_config pc302gem_config = {
 	.init = macb_init,
 };
 
+static const struct macb_config sama5d2_config = {
+	.caps = 0,
+	.dma_burst_length = 16,
+	.clk_init = macb_clk_init,
+	.init = macb_init,
+};
+
 static const struct macb_config sama5d3_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
@@ -2756,6 +2763,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,macb" },
 	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
 	{ .compatible = "cdns,gem", .data = &pc302gem_config },
+	{ .compatible = "atmel,sama5d2-gem", .data = &sama5d2_config },
 	{ .compatible = "atmel,sama5d3-gem", .data = &sama5d3_config },
 	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
 	{ .compatible = "cdns,at91rm9200-emac", .data = &emac_config },
-- 
2.1.3
