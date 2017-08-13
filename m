From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 3/4] net: sh_eth: constify platform_device_id
Date: Sun, 13 Aug 2017 16:42:42 +0530
Message-ID: <1502622762-11275-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, madalin.bucur@nxp.com,
        davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
        grygorii.strashko@ti.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_device_id are not supposed to change at runtime. All functions
working with platform_device_id provided by <linux/platform_device.h>
work with const platform_device_id. So mark the non-const structs as
const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d2dc0a8..d2e88a3 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3402,7 +3402,7 @@ static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 #define SH_ETH_PM_OPS NULL
 #endif
 
-static struct platform_device_id sh_eth_id_table[] = {
+static const struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
 	{ "sh7724-ether", (kernel_ulong_t)&sh7724_data },
-- 
2.7.4
