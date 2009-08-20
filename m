From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/3] r6040: remove unused pioaddr variable
Date: Thu, 20 Aug 2009 13:26:12 +0200
Message-ID: <200908201326.14630.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark@bifferos.com,
	bifferos <bifferos@yahoo.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:39465 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbZHTL0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 07:26:17 -0400
Received: by fxm17 with SMTP id 17so380883fxm.37
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 04:26:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Kelly <mark@bifferos.com>

This patch removes the unused pioaddr variable.

Signed-off-by: Mark Kelly <mark@bifferos.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 840677f..60bd010 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1091,7 +1091,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	int err, io_size = R6040_IO_SIZE;
 	static int card_idx = -1;
 	int bar = 0;
-	long pioaddr;
 	u16 *adrp;
 
 	printk(KERN_INFO "%s\n", version);
@@ -1121,7 +1120,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	pioaddr = pci_resource_start(pdev, bar);	/* IO map base address */
 	pci_set_master(pdev);
 
 	dev = alloc_etherdev(sizeof(struct r6040_private));
