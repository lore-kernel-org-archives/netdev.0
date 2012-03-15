From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 01/34] sungem: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:56:58 +0100
Message-ID: <a41b1ae9c479062e3e5695ef1f1194c6df354b19.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51796 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932356Ab2CON7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:21 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/sun/sungem.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index ba04159..8707d59 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2899,7 +2899,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	}
 
 	gp->pdev = pdev;
-	dev->base_addr = (long) pdev;
 	gp->dev = dev;
 
 	gp->msg_enable = DEFAULT_MSG;
@@ -2973,7 +2972,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	netif_napi_add(dev, &gp->napi, gem_poll, 64);
 	dev->ethtool_ops = &gem_ethtool_ops;
 	dev->watchdog_timeo = 5 * HZ;
-	dev->irq = pdev->irq;
 	dev->dma = 0;
 
 	/* Set that now, in case PM kicks in now */
-- 
1.7.7.6
