From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: ucc_geth: fix spelling mistake "propperty" -> "property"
Date: Sun, 28 Aug 2016 12:03:27 +0100
Message-ID: <20160828110327.10205-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_warn message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5bf1ade..186ef8f 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3756,7 +3756,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 			return -EINVAL;
 		}
 		if ((*prop < QE_CLK_NONE) || (*prop > QE_CLK24)) {
-			pr_err("invalid rx-clock propperty\n");
+			pr_err("invalid rx-clock property\n");
 			return -EINVAL;
 		}
 		ug_info->uf_info.rx_clock = *prop;
-- 
2.9.3
