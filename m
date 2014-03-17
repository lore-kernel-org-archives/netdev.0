From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] via: fix a punctuation typo
Date: Mon, 17 Mar 2014 15:52:17 +0800
Message-ID: <5326A9B1.7050609@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45703 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbaCQHwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 03:52:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In generic, after an assignment, we use ';' instead of ','.
Although, it won't hurt.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 drivers/net/ethernet/via/via-rhine.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 5bc1a2d..9d93fa1 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1022,7 +1022,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* The chip-specific entries in the device structure. */
 	dev->netdev_ops = &rhine_netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops,
+	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	netif_napi_add(dev, &rp->napi, rhine_napipoll, 64);
-- 
1.7.12
