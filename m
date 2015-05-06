From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH v3 2/4] net: macb: Add compatible string for Zynq Ultrascale+ MPSoC
Date: Wed, 6 May 2015 22:27:16 +0530
Message-ID: <1430931438-32592-2-git-send-email-harinik@xilinx.com>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add compatible string and config structure for Zynq Ultrascale+ MPSoC

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---

Added in v3

---
 drivers/net/ethernet/cadence/macb.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4104d49..bbe5656 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2684,6 +2684,13 @@ static const struct macb_config emac_config = {
 	.init = at91ether_init,
 };
 
+static const struct macb_config zynqmp_config = {
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.dma_burst_length = 16,
+	.clk_init = macb_clk_init,
+	.init = macb_init,
+};
+
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb", .data = &at91sam9260_config },
@@ -2694,6 +2701,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
 	{ .compatible = "cdns,at91rm9200-emac", .data = &emac_config },
 	{ .compatible = "cdns,emac", .data = &emac_config },
+	{ .compatible = "cdns,zynqmp-gem", .data = &zynqmp_config},
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
-- 
1.7.9.5
