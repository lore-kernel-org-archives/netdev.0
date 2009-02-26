From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/15] 3c59x: get rid of non-const printk warnings
Date: Thu, 26 Feb 2009 12:19:24 -0800
Message-ID: <20090226201949.304637267@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38658 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=3c59x-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c59x.c	2009-02-26 12:06:07.000000000 -0800
+++ b/drivers/net/3c59x.c	2009-02-26 12:12:27.000000000 -0800
@@ -102,8 +102,8 @@ static int vortex_debug = 1;
 #include <linux/delay.h>
 
 
-static char version[] __devinitdata =
-DRV_NAME ": Donald Becker and others.\n";
+static const char version[] __devinitconst =
+	DRV_NAME ": Donald Becker and others.\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("3Com 3c59x/3c9xx ethernet driver ");
@@ -2908,7 +2908,7 @@ static void vortex_get_drvinfo(struct ne
 		strcpy(info->bus_info, pci_name(VORTEX_PCI(vp)));
 	} else {
 		if (VORTEX_EISA(vp))
-			sprintf(info->bus_info, dev_name(vp->gendev));
+			strcpy(info->bus_info, dev_name(vp->gendev));
 		else
 			sprintf(info->bus_info, "EISA 0x%lx %d",
 					dev->base_addr, dev->irq);

-- 

