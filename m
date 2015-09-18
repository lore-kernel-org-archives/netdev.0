From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 1/6] net: arc: Fix module autoload for OF platform driver
Date: Fri, 18 Sep 2015 17:54:00 +0200
Message-ID: <20150918155400.GA24716@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform driver has a OF device ID table but the OF module
alias information is not created so module autoloading won't work.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/net/ethernet/arc/emac_arc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/arc/emac_arc.c b/drivers/net/ethernet/arc/emac_arc.c
index f9cb99b..ffd1805 100644
--- a/drivers/net/ethernet/arc/emac_arc.c
+++ b/drivers/net/ethernet/arc/emac_arc.c
@@ -78,6 +78,7 @@ static const struct of_device_id emac_arc_dt_ids[] = {
 	{ .compatible = "snps,arc-emac" },
 	{ /* Sentinel */ }
 };
+MODULE_DEVICE_TABLE(of, emac_arc_dt_ids);
 
 static struct platform_driver emac_arc_driver = {
 	.probe = emac_arc_probe,
-- 
2.4.6
