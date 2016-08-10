From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net: hns: fix typo in g_gmac_stats_string[]
Date: Wed, 10 Aug 2016 17:48:36 +0200
Message-ID: <1470844116-13545-1-git-send-email-fabf@skynet.be>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fabf@skynet.be, davem@davemloft.net
To: Yisen Zhuang <yisen.zhuang@huawei.com>,
	Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/gamc/gmac/

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 1235c7f..1e1eb92 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -17,7 +17,7 @@ static const struct mac_stats_string g_gmac_stats_string[] = {
 	{"gmac_rx_octets_total_ok", MAC_STATS_FIELD_OFF(rx_good_bytes)},
 	{"gmac_rx_octets_bad", MAC_STATS_FIELD_OFF(rx_bad_bytes)},
 	{"gmac_rx_uc_pkts", MAC_STATS_FIELD_OFF(rx_uc_pkts)},
-	{"gamc_rx_mc_pkts", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
+	{"gmac_rx_mc_pkts", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
 	{"gmac_rx_bc_pkts", MAC_STATS_FIELD_OFF(rx_bc_pkts)},
 	{"gmac_rx_pkts_64octets", MAC_STATS_FIELD_OFF(rx_64bytes)},
 	{"gmac_rx_pkts_65to127", MAC_STATS_FIELD_OFF(rx_65to127)},
-- 
2.8.1
