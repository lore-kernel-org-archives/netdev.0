From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 4/9] net: hns: delete redundant parenthese
Date: Fri, 1 Jul 2016 17:34:08 +0800
Message-ID: <1467365653-83331-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11037 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbcGAJQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:16:16 -0400
In-Reply-To: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

According to the previous review comments from Andy, this patch
deletes the redundant parens in the patch.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index b9d01ea..e36ee22 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -2565,7 +2565,7 @@ static char *hns_dsaf_get_node_stats_strings(char *data, int node,
 	buff += ETH_GSTRING_LEN;
 	snprintf(buff, ETH_GSTRING_LEN, "innod%d_stp_drop_pkts", node);
 	buff += ETH_GSTRING_LEN;
-	if ((node < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
+	if (node < DSAF_SERVICE_NW_NUM && !is_ver1) {
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
 			snprintf(buff, ETH_GSTRING_LEN,
 				 "inod%d_pfc_prio%d_pkts", node, i);
@@ -2604,7 +2604,7 @@ static u64 *hns_dsaf_get_node_stats(struct dsaf_device *ddev, u64 *data,
 	p[10] = hw_stats->local_addr_false;
 	p[11] = hw_stats->vlan_drop;
 	p[12] = hw_stats->stp_drop;
-	if ((node_num < DSAF_SERVICE_NW_NUM) && (!is_ver1)) {
+	if (node_num < DSAF_SERVICE_NW_NUM && !is_ver1) {
 		for (i = 0; i < DSAF_PRIO_NR; i++) {
 			p[13 + i] = hw_stats->rx_pfc[i];
 			p[13 + i + DSAF_PRIO_NR] = hw_stats->tx_pfc[i];
-- 
1.9.1
