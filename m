From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 10/28] net: ethernet: stmicro: stmmac: drop owner assignment from platform_drivers
Date: Sun, 21 Dec 2014 22:14:31 +0100
Message-ID: <1419196495-9626-11-git-send-email-wsa@the-dreams.de>
References: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419196495-9626-1-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform_driver does not need to set an owner, it will be populated by the
driver core.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
Generated with coccinelle. SmPL file is in the introductory msg. The big
cleanup was pulled in this merge window. This series catches the bits fallen
through. The patches shall go in via the subsystem trees.

 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4032b170fe24..3039de2465ba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -430,7 +430,6 @@ static struct platform_driver stmmac_pltfr_driver = {
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		   .name = STMMAC_RESOURCE_NAME,
-		   .owner = THIS_MODULE,
 		   .pm = &stmmac_pltfr_pm_ops,
 		   .of_match_table = of_match_ptr(stmmac_dt_ids),
 	},
-- 
2.1.3
