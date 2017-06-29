From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: freescale: gianfar : constify dev_pm_ops structures.
Date: Thu, 29 Jun 2017 11:26:06 +0530
Message-ID: <8a8554d003a6e7bb2435d55258a9120eb5822a82.1498715654.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: claudiu.manoil@freescale.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_pm_ops are not supposed to change at runtime. All functions
working with dev_pm_ops provided by <linux/device.h> work with const
dev_pm_ops. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  19057	    392	      0	  19449	   4bf9	drivers/net/ethernet/freescale/gianfar.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  19249	    192	      0	  19441	   4bf1	drivers/net/ethernet/freescale/gianfar.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0ff166e..e3b0501 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1718,7 +1718,7 @@ static int gfar_restore(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops gfar_pm_ops = {
+static const struct dev_pm_ops gfar_pm_ops = {
 	.suspend = gfar_suspend,
 	.resume = gfar_resume,
 	.freeze = gfar_suspend,
-- 
1.9.1
