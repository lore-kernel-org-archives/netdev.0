From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 2/5] sc92031: remove meaningless version string
Date: Mon, 12 Jan 2009 21:21:48 -0200
Message-ID: <1231802511-14825-2-git-send-email-cesarb@cesarb.net>
References: <496BD04F.2050502@cesarb.net>
Cc: netdev@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-01.mandic.com.br ([200.225.81.132]:48980 "EHLO
	smtp-01.mandic.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbZALX2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 18:28:33 -0500
In-Reply-To: <496BD04F.2050502@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The version string makes no sense anymore, since this driver is only
maintained within the kernel.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/sc92031.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 40b39af..07bd13b 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -37,7 +37,6 @@
 
 #define SC92031_NAME "sc92031"
 #define SC92031_DESCRIPTION "Silan SC92031 PCI Fast Ethernet Adapter driver"
-#define SC92031_VERSION "2.0c"
 
 /* BAR 0 is MMIO, BAR 1 is PIO */
 #ifndef SC92031_USE_BAR
@@ -1264,7 +1263,6 @@ static void sc92031_ethtool_get_drvinfo(struct net_device *dev,
 	struct pci_dev *pdev = priv->pdev;
 
 	strcpy(drvinfo->driver, SC92031_NAME);
-	strcpy(drvinfo->version, SC92031_VERSION);
 	strcpy(drvinfo->bus_info, pci_name(pdev));
 }
 
@@ -1625,4 +1623,3 @@ module_exit(sc92031_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Cesar Eduardo Barros <cesarb@cesarb.net>");
 MODULE_DESCRIPTION(SC92031_DESCRIPTION);
-MODULE_VERSION(SC92031_VERSION);
-- 
1.6.1.dirty

