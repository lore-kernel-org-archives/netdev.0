From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 4/4] net: stmmac: sun8i: Remove the compatibles
Date: Fri, 25 Aug 2017 21:12:17 +0200
Message-ID: <20170825191217.10278-5-maxime.ripard@free-electrons.com>
References: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        f.fainelli@gmail.com, clabbe.montjoie@gmail.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org
To: arm@kernel.org, davem@davemloft.net, Chen-Yu Tsai <wens@csie.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the bindings have been controversial, and we follow the DT stable ABI
rule, we shouldn't let a driver with a DT binding that might change slip
through in a stable release.

Remove the compatibles to make sure the driver will not probe and no-one
will start using the binding currently implemented. This commit will
obviously need to be reverted in due time.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..39c2122a4f26 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -979,14 +979,6 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 }
 
 static const struct of_device_id sun8i_dwmac_match[] = {
-	{ .compatible = "allwinner,sun8i-h3-emac",
-		.data = &emac_variant_h3 },
-	{ .compatible = "allwinner,sun8i-v3s-emac",
-		.data = &emac_variant_v3s },
-	{ .compatible = "allwinner,sun8i-a83t-emac",
-		.data = &emac_variant_a83t },
-	{ .compatible = "allwinner,sun50i-a64-emac",
-		.data = &emac_variant_a64 },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, sun8i_dwmac_match);
-- 
2.13.5
