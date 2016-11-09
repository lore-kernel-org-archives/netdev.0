From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 04/17] net: hns: set default mac pause time to 0xffff
Date: Wed, 9 Nov 2016 18:13:48 +0000
Message-ID: <20161109181401.913728-5-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Daode Huang <huangdaode@hisilicon.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

The default mac pause time set to 0xff which is too short for pausing,
this patch change it to the max value 0xffff.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Reviewed-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 1d941d5..a9b0cb3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -31,7 +31,7 @@
 #define MAC_MIN_MTU		68
 #define MAC_MAX_MTU_DBG		MAC_DEFAULT_MTU
 
-#define MAC_DEFAULT_PAUSE_TIME 0xff
+#define MAC_DEFAULT_PAUSE_TIME 0xffff
 
 #define MAC_GMAC_IDX 0
 #define MAC_XGMAC_IDX 1
-- 
1.7.9.5
