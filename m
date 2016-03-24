From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net 4/7] net: hns: remove useless variable assignment and comment
Date: Thu, 24 Mar 2016 19:08:03 +0800
Message-ID: <1458817686-159708-5-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41774 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447AbcCXKt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 06:49:29 -0400
In-Reply-To: <1458817686-159708-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qianqian Xie <xieqianqian@huawei.com>

The variable head in hns_nic_tx_fini_pro has read a value, but it is
obviously no use. The patch will fix it.
And the comment is nothing to do with the routine, so it has to be removed

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 71aa37b..f0c9a41 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -913,10 +913,7 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
-	int head = ring->next_to_clean;
-
-	/* for hardware bug fixed */
-	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 
 	if (head != ring->next_to_clean) {
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-- 
1.9.1
