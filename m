From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 06/17] net: hns: delete redundant macro definition
Date: Wed, 9 Nov 2016 18:13:50 +0000
Message-ID: <20161109181401.913728-7-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Weiwei Deng <dengweiwei@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qianqian Xie <xieqianqian@huawei.com>

This patch deletes redundant macro definitions in hns drivers.
And change the .h file containing relation to make the layers
more clearly

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Weiwei Deng <dengweiwei@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |    3 ---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    1 -
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 2d0cb60..193248f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -18,9 +18,6 @@
 #include "hns_dsaf_rcb.h"
 
 #define AE_NAME_PORT_ID_IDX 6
-#define ETH_STATIC_REG	 1
-#define ETH_DUMP_REG	 5
-#define ETH_GSTRING_LEN	32
 
 static struct hns_mac_cb *hns_get_mac_cb(struct hnae_handle *handle)
 {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index a9b0cb3..ca7e175 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -407,7 +407,7 @@ struct mac_driver {
 };
 
 struct mac_stats_string {
-	char desc[64];
+	char desc[ETH_GSTRING_LEN];
 	unsigned long offset;
 };
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 3eb8b4d..f5505e8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -314,7 +314,6 @@
 #define PPE_COM_INTEN_REG			0x110
 #define PPE_COM_RINT_REG			0x114
 #define PPE_COM_INTSTS_REG			0x118
-#define PPE_COM_COMMON_CNT_CLR_CE_REG		0x1120
 #define PPE_COM_HIS_RX_PKT_QID_DROP_CNT_REG	0x300
 #define PPE_COM_HIS_RX_PKT_QID_OK_CNT_REG	0x600
 #define PPE_COM_HIS_TX_PKT_QID_ERR_CNT_REG	0x900
-- 
1.7.9.5
