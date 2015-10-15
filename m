From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next] net: hisilicon: fixes a bug when using ethtool -S
Date: Thu, 15 Oct 2015 12:40:34 +0800
Message-ID: <1444884034-113975-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<yankejian@huawei.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

this patch fixes a bug in hns driver. when we want to get statistic info
by using ethtool -S, it shows us there are 3 wrong counters info. because
the strings related to the registers are wrong. it needs to modify the
strings which give us wrong info.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index dab5ecf..802d554 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -51,9 +51,9 @@ static const struct mac_stats_string g_xgmac_stats_string[] = {
 	{"xgmac_rx_bad_pkt_from_dsaf", MAC_STATS_FIELD_OFF(rx_bad_from_sw)},
 	{"xgmac_tx_bad_pkt_64tomax", MAC_STATS_FIELD_OFF(tx_bad_pkts)},
 
-	{"xgmac_rx_not_well_pkt", MAC_STATS_FIELD_OFF(rx_fragment_err)},
-	{"xgmac_rx_good_well_pkt", MAC_STATS_FIELD_OFF(rx_undersize)},
-	{"xgmac_rx_total_pkt", MAC_STATS_FIELD_OFF(rx_under_min)},
+	{"xgmac_rx_bad_pkts_minto64", MAC_STATS_FIELD_OFF(rx_fragment_err)},
+	{"xgmac_rx_good_pkts_minto64", MAC_STATS_FIELD_OFF(rx_undersize)},
+	{"xgmac_rx_total_pkts_minto64", MAC_STATS_FIELD_OFF(rx_under_min)},
 	{"xgmac_rx_pkt_64", MAC_STATS_FIELD_OFF(rx_64bytes)},
 	{"xgmac_rx_pkt_65to127", MAC_STATS_FIELD_OFF(rx_65to127)},
 	{"xgmac_rx_pkt_128to255", MAC_STATS_FIELD_OFF(rx_128to255)},
-- 
1.9.1
