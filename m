From: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 06/10] net: hns: sort the header file by alphabetical order
Date: Thu, 28 Apr 2016 15:01:38 +0800
Message-ID: <1461826902-51368-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461826902-51368-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>

This patch tunes the header file by the alphabetical order.

Signed-off-by: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Signed-off-by: Yuzeng Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 12 ++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  4 ++--
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 353b9e7..3730385 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -7,18 +7,18 @@
  * (at your option) any later version.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/netdevice.h>
-#include <linux/phy_fixed.h>
 #include <linux/interrupt.h>
-#include <linux/platform_device.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
+#include <linux/phy_fixed.h>
+#include <linux/platform_device.h>
 
-#include "hns_dsaf_misc.h"
 #include "hns_dsaf_main.h"
+#include "hns_dsaf_misc.h"
 #include "hns_dsaf_rcb.h"
 
 #define MAC_EN_FLAG_V		0xada0328
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index b418d42..98e0e83 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -7,22 +7,22 @@
  * (at your option) any later version.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
+#include <linux/device.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/platform_device.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
-#include <linux/device.h>
+#include <linux/platform_device.h>
 #include <linux/vmalloc.h>
 
+#include "hns_dsaf_mac.h"
 #include "hns_dsaf_main.h"
-#include "hns_dsaf_rcb.h"
 #include "hns_dsaf_ppe.h"
-#include "hns_dsaf_mac.h"
+#include "hns_dsaf_rcb.h"
 
 const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
 	[DSAF_MODE_DISABLE_2PORT_64VM] = "2port-64vf",
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 91e0382..67c8b9e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -7,10 +7,10 @@
  * (at your option) any later version.
  */
 
-#include "hns_dsaf_misc.h"
 #include "hns_dsaf_mac.h"
-#include "hns_dsaf_reg.h"
+#include "hns_dsaf_misc.h"
 #include "hns_dsaf_ppe.h"
+#include "hns_dsaf_reg.h"
 
 void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
 		      u16 speed, int data)
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
