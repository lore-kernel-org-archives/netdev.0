From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next 13/18] net: hns: Clean redundant code from hns_mdio.c file
Date: Fri, 31 Mar 2017 18:48:47 +0100
Message-ID: <20170331174852.13600-14-salil.mehta@huawei.com>
References: <20170331174852.13600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331174852.13600-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

This patch cleans the redundant code from  hns_mdio.c.

Reported-by: Ping Zhang <zhangping5@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns_mdio.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c b/drivers/net/ethernet/hisilicon/hns_mdio.c
index 501eb20..fad1c5b 100644
--- a/drivers/net/ethernet/hisilicon/hns_mdio.c
+++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
@@ -23,17 +23,9 @@
 #include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <linux/regmap.h>
-#include <linux/spinlock_types.h>
 
 #define MDIO_DRV_NAME "Hi-HNS_MDIO"
 #define MDIO_BUS_NAME "Hisilicon MII Bus"
-#define MDIO_DRV_VERSION "1.3.0"
-#define MDIO_COPYRIGHT "Copyright(c) 2015 Huawei Corporation."
-#define MDIO_DRV_STRING MDIO_BUS_NAME
-#define MDIO_DEFAULT_DEVICE_DESCR MDIO_BUS_NAME
-
-#define MDIO_CTL_DEV_ADDR(x)	(x & 0x1f)
-#define MDIO_CTL_PORT_ADDR(x)	((x & 0x1f) << 5)
 
 #define MDIO_TIMEOUT			1000000
 
@@ -64,9 +56,7 @@ struct hns_mdio_device {
 #define MDIO_CMD_DEVAD_S	0
 #define MDIO_CMD_PRTAD_M	0x1f
 #define MDIO_CMD_PRTAD_S	5
-#define MDIO_CMD_OP_M		0x3
 #define MDIO_CMD_OP_S		10
-#define MDIO_CMD_ST_M		0x3
 #define MDIO_CMD_ST_S		12
 #define MDIO_CMD_START_B	14
 
-- 
2.7.4
