From: Colin King <colin.king@canonical.com>
Subject: [PATCH][-next] net: macb: remove extraneous return when MACB_EXT_DESC is defined
Date: Tue,  4 Jul 2017 16:09:59 +0100
Message-ID: <20170704150959.18315-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@microchip.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

When macro MACB_EXT_DESC is defined we end up with two identical
return statements and just one is sufficient. Remove the extra
return.

Detected by CoverityScan, CID#1449361 ("Structurally dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cadence/macb_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 41e5711544fc..e69ebdd65658 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -146,7 +146,6 @@ static unsigned int macb_adj_dma_desc_idx(struct macb *bp, unsigned int desc_idx
 	default:
 		break;
 	}
-	return desc_idx;
 #endif
 	return desc_idx;
 }
-- 
2.11.0
