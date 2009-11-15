From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next-2.6] r6040: fix version printing
Date: Sun, 15 Nov 2009 14:49:43 +0100
Message-ID: <200911151449.43750.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:14763 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbZKONtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 08:49:41 -0500
Received: by ey-out-2122.google.com with SMTP id 9so1617764eyd.19
        for <netdev@vger.kernel.org>; Sun, 15 Nov 2009 05:49:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The version string already contains the printk level
specifying it again results in the following message
being printed:
<6>r6040: RDC R6040 NAPI ...

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 7dfcb58..8b14c6e 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1085,7 +1085,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	int bar = 0;
 	u16 *adrp;
 
-	printk(KERN_INFO "%s\n", version);
+	printk("%s\n", version);
 
 	err = pci_enable_device(pdev);
 	if (err)
