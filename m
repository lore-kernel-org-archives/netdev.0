From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 2/6] net: systemport: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 17:54:30 +0200
Message-ID: <20150918155430.GA24767@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This platform driver has a OF device ID table but the OF module
alias information is not created so module autoloading won't work.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index b9a5a97..f1b5364 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -2079,6 +2079,7 @@ static const struct of_device_id bcm_sysport_of_match[] = {
 	{ .compatible = "brcm,systemport" },
 	{ /* sentinel */ }
 };
+MODULE_DEVICE_TABLE(of, bcm_sysport_of_match);
 
 static struct platform_driver bcm_sysport_driver = {
 	.probe	= bcm_sysport_probe,
-- 
2.4.6
