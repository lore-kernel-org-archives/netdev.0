From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH] net: hisilicon: Remove .owner assignment from platform_driver
Date: Fri, 30 Oct 2015 10:50:54 +0800
Message-ID: <1446173454-227326-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<lisheng011@huawei.com>, <liguozhu@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_driver doesn't need to set .owner, because
platform_driver_register() will set it.

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 83c02a8..562eff9 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1914,7 +1914,6 @@ MODULE_DEVICE_TABLE(of, hns_enet_of_match);
 static struct platform_driver hns_nic_dev_driver = {
 	.driver = {
 		.name = "hns-nic",
-		.owner = THIS_MODULE,
 		.of_match_table = hns_enet_of_match,
 	},
 	.probe = hns_nic_dev_probe,
-- 
1.9.1
