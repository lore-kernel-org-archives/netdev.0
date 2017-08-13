From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 2/4] net: dpaa_eth: constify platform_device_id
Date: Sun, 13 Aug 2017 16:42:08 +0530
Message-ID: <1502622728-11224-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, madalin.bucur@nxp.com,
        davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
        grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_device_id are not supposed to change at runtime. All functions
working with platform_device_id provided by <linux/platform_device.h>
work with const platform_device_id. So mark the non-const structs as
const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 757b873..4521b33 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2829,7 +2829,7 @@ static int dpaa_remove(struct platform_device *pdev)
 	return err;
 }
 
-static struct platform_device_id dpaa_devtype[] = {
+static const struct platform_device_id dpaa_devtype[] = {
 	{
 		.name = "dpaa-ethernet",
 		.driver_data = 0,
-- 
2.7.4
