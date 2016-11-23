From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] drivers: net: davinci_mdio: use builtin_platform_driver
Date: Wed, 23 Nov 2016 22:45:43 +0800
Message-ID: <055763562f90fd7e2d311308e1d731ba93c3eea9.1479912302.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use builtin_platform_driver() helper to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 33df340..b3f0a12 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -536,11 +536,7 @@ static struct platform_driver davinci_mdio_driver = {
 	.remove = davinci_mdio_remove,
 };
 
-static int __init davinci_mdio_init(void)
-{
-	return platform_driver_register(&davinci_mdio_driver);
-}
-device_initcall(davinci_mdio_init);
+builtin_platform_driver(davinci_mdio_driver);
 
 static void __exit davinci_mdio_exit(void)
 {
-- 
2.9.3
