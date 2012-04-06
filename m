From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 01/39] sungem: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:15 +0200
Message-ID: <560cb3215c2055fc4f79fef91ed7c9e337785d25.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43445 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755895Ab2DFKKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:37 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
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
