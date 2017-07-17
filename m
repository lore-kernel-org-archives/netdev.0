From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] net: bcmgenet: return NULL rather than 0 for null pointer
Date: Mon, 17 Jul 2017 10:07:25 +0100
Message-ID: <20170717090725.32540-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't return plain integer 0, instead return NULL

Fixes sparse warning:
warning: Using plain integer as NULL pointer

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 7b0b399aaedd..13a35f504081 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1303,7 +1303,7 @@ static struct sk_buff *bcmgenet_free_tx_cb(struct device *dev,
 		dma_unmap_addr_set(cb, dma_addr, 0);
 	}
 
-	return 0;
+	return NULL;
 }
 
 /* Simple helper to free a receive control block's resources */
-- 
2.11.0
