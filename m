From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V2 net-next] net-next/hinic: Fix MTU limitation
Date: Mon, 28 Aug 2017 01:20:26 +0800
Message-ID: <1503854426-42046-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <zhaochen6@huawei.com>, <andrew@lunn.ch>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:5467 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdH0RVe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 13:21:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the hw MTU limitation by setting max_mtu

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index ae7ad48..eb53bd9 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -919,6 +919,7 @@ static int nic_dev_init(struct pci_dev *pdev)
 
 	netdev->netdev_ops = &hinic_netdev_ops;
 	netdev->ethtool_ops = &hinic_ethtool_ops;
+	netdev->max_mtu = ETH_MAX_MTU;
 
 	nic_dev = netdev_priv(netdev);
 	nic_dev->netdev = netdev;
-- 
1.9.1
