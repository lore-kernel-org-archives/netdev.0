From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH 1/2] sh_eth: align usage of sh_eth_modify() with rest of driver
Date: Wed,  1 Feb 2017 15:41:54 +0100
Message-ID: <20170201144155.17123-2-niklas.soderlund+renesas@ragnatech.se>
References: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be consistent with the rest of the driver when setting bits using
sh_eth_modify() the same bit should also be cleared. This have no
functional change and should have been done from the start.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 2f08d2735fe25e4d..f9134c818ac6ef53 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3271,7 +3271,7 @@ static int sh_eth_wol_setup(struct net_device *ndev)
 	sh_eth_write(ndev, EESIPR_ECIIP, EESIPR);
 
 	/* Enable MagicPacket */
-	sh_eth_modify(ndev, ECMR, 0, ECMR_MPDE);
+	sh_eth_modify(ndev, ECMR, ECMR_MPDE, ECMR_MPDE);
 
 	/* Increased clock usage so device won't be suspended */
 	clk_enable(mdp->clk);
-- 
2.11.0
