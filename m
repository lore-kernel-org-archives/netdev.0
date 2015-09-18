From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 5/6] net: ks8851: Fix module autoload for OF platform driver
Date: Fri, 18 Sep 2015 17:55:57 +0200
Message-ID: <20150918155557.GA24836@goodgumbo.baconseed.org>
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
 drivers/net/ethernet/micrel/ks8851.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 66d4ab7..60f43ec 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1601,6 +1601,7 @@ static const struct of_device_id ks8851_match_table[] = {
 	{ .compatible = "micrel,ks8851" },
 	{ }
 };
+MODULE_DEVICE_TABLE(of, ks8851_match_table);
 
 static struct spi_driver ks8851_driver = {
 	.driver = {
-- 
2.4.6
