From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 2/2 net-next v3.16]r8169:  Place rtl_netdev_opts after alls functions is ready
Date: Sat, 19 Mar 2016 15:10:27 +0200
Message-ID: <1458393027-1927-2-git-send-email-asd@marian1000.go.ro>
References: <1458393027-1927-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:35358 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbcCSNi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 09:38:26 -0400
In-Reply-To: <1458393027-1927-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On multi cpu is posible do not keep in track alls tasks and
 rtl_netdev_opts is placed after alls functions is fixed on structure
 (rtl8169_private) and after MAC ADDRESS is added on structure.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2594bbb..c798349 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7008,7 +7008,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->netdev_ops = &rtl_netdev_ops;
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 	tp->pci_dev = pdev;
@@ -7152,6 +7151,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 
+	dev->netdev_ops = &rtl_netdev_ops;
 	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 
-- 
2.1.4
