From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 3/9] net: hns: change code style from a = a + x to a += x
Date: Thu, 30 Jun 2016 15:25:03 +0800
Message-ID: <1467271509-63162-4-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch fixes the code style in hns driver. Change it from
"buff = buff + xxx" to "buff += xxx". The reveiw comments is
from andy.

Reviewed-by: Andriy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 32 +++++++++++-----------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 67e8e13..b9d01ea 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2540,45 +2540,45 @@ static char *hns_dsaf_get_node_stats_strings(char *data, int node,
 	bool is_ver1 = AE_IS_VER1(dsaf_dev->dsaf_ver);
 
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_pad_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_manage_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pkt_id", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pause_frame", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_release_buf_num", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_sbm_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_crc_false_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_bp_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_lookup_rslt_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_local_rslt_fail_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_vlan_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_stp_drop_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 	if ((node < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
 			snprintf(buff, ETH_GSTRING_LEN,
 				 "inod%d_pfc_prio%d_pkts", node, i);
-			buff = buff + ETH_GSTRING_LEN;
+			buff += ETH_GSTRING_LEN;
 		}
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
 			snprintf(buff, ETH_GSTRING_LEN,
 				 "onod%d_pfc_prio%d_pkts", node, i);
-			buff = buff + ETH_GSTRING_LEN;
+			buff += ETH_GSTRING_LEN;
 		}
 	}
 	snprintf(buff, ETH_GSTRING_LEN, "onnod%d_tx_pkts", node);
-	buff = buff + ETH_GSTRING_LEN;
+	buff += ETH_GSTRING_LEN;
 
 	return buff;
 }
-- 
1.9.1
