From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 06/13] net: hns: sort the header file by
 alphabetical order
Date: Sat, 23 Apr 2016 17:05:10 +0800
Message-ID: <1461402317-136499-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, salil.mehta@huawei.com, yankejian@huawei.com,
 xieqianqian@huawei.com, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk,
 catalin.marinas@arm.com, lipeng321@huawei.com, will.deacon@arm.com,
 linuxarm@huawei.com, xuwei5@hisilicon.com, robh+dt@kernel.org,
 huangdaode@hisilicon.com, galak@codeaurora.org, liguozhu@huawei.com,
 davem@davemloft.net
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461402317-136499-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch tunes the header file by the alphabetical order.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
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
