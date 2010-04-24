From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/4] e1000e: Save irq into netdev structure
Date: Fri, 23 Apr 2010 17:27:08 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004231715490.15627@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54849 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab0DXA1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 20:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set net->devirq to pdev->irq.  This should be consistent with other
drivers.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5f70c43..4f5034a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5073,6 +5062,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
+	netdev->irq = pdev->irq;
+
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
 	hw = &adapter->hw;
