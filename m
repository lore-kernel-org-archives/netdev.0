From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 07/17] net: hns: modify ethtool statistics value error
Date: Wed, 9 Nov 2016 18:13:51 +0000
Message-ID: <20161109181401.913728-8-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Qianqian Xie <xieqianqian@huawei.com>,
        Jun He <hjat2005@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55022 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754561AbcKISP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:15:29 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

This patch modify the gmac_rx_filt_pkt and gmac_rx_octets_total_filt
statistics value. The two statistics is inconsistent with register,
and just the opposite.

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Jun He <hjat2005@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 1e1eb92..3382441 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -37,8 +37,8 @@
 	{"gmac_rx_very_long_err", MAC_STATS_FIELD_OFF(rx_long_err)},
 	{"gmac_rx_runt_err", MAC_STATS_FIELD_OFF(rx_minto64)},
 	{"gmac_rx_short_err", MAC_STATS_FIELD_OFF(rx_under_min)},
-	{"gmac_rx_filt_pkt", MAC_STATS_FIELD_OFF(rx_filter_bytes)},
-	{"gmac_rx_octets_total_filt", MAC_STATS_FIELD_OFF(rx_filter_pkts)},
+	{"gmac_rx_filt_pkt", MAC_STATS_FIELD_OFF(rx_filter_pkts)},
+	{"gmac_rx_octets_total_filt", MAC_STATS_FIELD_OFF(rx_filter_bytes)},
 	{"gmac_rx_overrun_cnt", MAC_STATS_FIELD_OFF(rx_fifo_overrun_err)},
 	{"gmac_rx_length_err", MAC_STATS_FIELD_OFF(rx_len_err)},
 	{"gmac_rx_fail_comma", MAC_STATS_FIELD_OFF(rx_comma_err)},
-- 
1.7.9.5
