From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] net: stmmac: fix bad merge conflict resolution
Date: Thu,  5 Sep 2013 18:01:41 -0700
Message-ID: <1378429301-19964-1-git-send-email-olof@lixom.net>
References: <20130905.163725.106795517693348522.davem@davemloft.net>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Olof Johansson <olof@lixom.net>
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130905.163725.106795517693348522.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Merge commit 06c54055bebf919249aa1eb68312887c3cfe77b4 did a bad conflict
resolution accidentally leaving out a closing brace. Add it back.

Signed-off-by: Olof Johansson <olof@lixom.net>
---

This breaks a handful of defconfigs on ARM, so it'd be good to see it
applied pretty quickly. Thanks!


-Olof

 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 7a00720..51c9069 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -87,6 +87,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	if (plat->force_thresh_dma_mode) {
 		plat->force_sf_dma_mode = 0;
 		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
+	}
 
 	return 0;
 }
-- 
1.7.10.4
