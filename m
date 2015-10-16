From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next v3 2/2] net: hisilicon fix a bug on Hisilicon Network Subsystem
Date: Fri, 16 Oct 2015 11:54:17 +0800
Message-ID: <1444967657-107994-3-git-send-email-huangdaode@hisilicon.com>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>,
	<lipeng321@huawei.com>
To: <davem@davemloft.net>, <arnd@arndb.de>, <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the wrong judgement of mac_id when get port num.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index f8f7347..026b386 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -179,7 +179,7 @@ static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 			return -EINVAL;
 		}
 	} else if (mac_cb->dsaf_dev->dsaf_mode < DSAF_MODE_MAX) {
-		if (mac_cb->mac_id <= DSAF_MAX_PORT_NUM_PER_CHIP) {
+		if (mac_cb->mac_id >= DSAF_MAX_PORT_NUM_PER_CHIP) {
 			dev_err(mac_cb->dev,
 				"input invalid,%s mac%d vmid%d!\n",
 				mac_cb->dsaf_dev->ae_dev.name,
-- 
1.9.1
