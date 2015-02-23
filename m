From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net-next] altera_tse: Correct typo in obtaining tx_fifo_depth from devicetree
Date: Mon, 23 Feb 2015 11:27:37 -0600
Message-ID: <1424712457-24291-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>,
	<setka@vsis.cz>
To: <netdev@vger.kernel.org>, <nios2-dev@lists.rocketboards.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlastimil Setka <setka@vsis.cz>

This patch corrects a typo in the way tx_fifo_depth is read from the
devicetree. This patch was submitted by Vlastimil about a week ago,
and is now cleaned up and resubmitted.

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index a1ee261..91ad435 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1407,7 +1407,7 @@ static int altera_tse_probe(struct platform_device *pdev)
 	}
 
 	if (of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
-				 &priv->rx_fifo_depth)) {
+				 &priv->tx_fifo_depth)) {
 		dev_err(&pdev->dev, "cannot obtain tx-fifo-depth\n");
 		ret = -ENXIO;
 		goto err_free_netdev;
-- 
1.9.1
