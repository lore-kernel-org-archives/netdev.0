From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: hisilicon: include linux/vmalloc.h in dsaf
Date: Fri, 16 Oct 2015 11:30:56 +0200
Message-ID: <4903569.oS7BSflIyn@wuerfel>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some configurations fail to build the hns dsaf code because of
a missing header file:

ethernet/hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_init':
ethernet/hisilicon/hns/hns_dsaf_main.c:1096:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
  priv->soft_mac_tbl = vzalloc(sizeof(*priv->soft_mac_tbl)

This adds the correct #include.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 26ae6c64d74c..473a860baf1d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -17,6 +17,8 @@
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
 #include <linux/device.h>
+#include <linux/vmalloc.h>
+
 #include "hns_dsaf_main.h"
 #include "hns_dsaf_rcb.h"
 #include "hns_dsaf_ppe.h"
