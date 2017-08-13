From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 4/4] net: ti: cpsw:: constify platform_device_id
Date: Sun, 13 Aug 2017 16:43:18 +0530
Message-ID: <1502622798-11330-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org
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
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1850e34..2866964 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2827,7 +2827,7 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 
 #define CPSW_QUIRK_IRQ		BIT(0)
 
-static struct platform_device_id cpsw_devtype[] = {
+static const struct platform_device_id cpsw_devtype[] = {
 	{
 		/* keep it for existing comaptibles */
 		.name = "cpsw",
-- 
2.7.4
