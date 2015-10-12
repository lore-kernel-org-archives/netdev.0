From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH net-next v2 2/2] hisilicon net: fix a bug on Hisilicon Network Subsystem
Date: Mon, 12 Oct 2015 11:23:45 +0800
Message-ID: <1444620225-2339-3-git-send-email-huangdaode@hisilicon.com>
References: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <arnd@arndb.de>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:8203 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbbJLDIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 23:08:17 -0400
In-Reply-To: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the wrong judgement of mac_id when get port num.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 95bf42a..e162e4a 100644
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
