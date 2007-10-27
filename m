From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/5][ATM]: [he] This patch removes the ancient version string.
Date: Sat, 27 Oct 2007 08:41:40 -0400
Message-ID: <200710271241.l9RCfeRG002890@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:51170 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083AbXJ0NXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 09:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 41d6b7e20dd6d57bec4f14697f654c8211ff5d57
Author: Adrian Bunk <bunk@stusta.de>
Date:   Fri Oct 26 07:29:47 2007 -0400

    [ATM]: [he] This patch removes the ancient version string.
    
    Signed-off-by: Adrian Bunk <bunk@stusta.de>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d33aba6..4f1c7e6 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1,5 +1,3 @@
-/* $Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $ */
-
 /*
 
   he.c
@@ -99,10 +97,6 @@
 #define HPRINTK(fmt,args...)	do { } while (0)
 #endif /* HE_DEBUG */
 
-/* version definition */
-
-static char *version = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
-
 /* declarations */
 
 static int he_open(struct atm_vcc *vcc);
@@ -366,7 +360,7 @@ he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 	struct he_dev *he_dev = NULL;
 	int err = 0;
 
-	printk(KERN_INFO "he: %s\n", version);
+	printk(KERN_INFO "ATM he driver\n");
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
@@ -2933,7 +2927,7 @@ he_proc_read(struct atm_dev *dev, loff_t *pos, char *page)
 
 	left = *pos;
 	if (!left--)
-		return sprintf(page, "%s\n", version);
+		return sprintf(page, "ATM he driver\n");
 
 	if (!left--)
 		return sprintf(page, "%s%s\n\n",
