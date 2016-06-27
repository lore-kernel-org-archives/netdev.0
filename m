From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 4/9] net: hns: delete redundant parens
Date: Mon, 27 Jun 2016 17:54:10 +0800
Message-ID: <1467021255-95900-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
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

According to the previous review comments from Andy, this patch
deletes the redundant parens in the patch.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
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
