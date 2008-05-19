From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] irda: remove CVS keywords
Date: Tue, 20 May 2008 01:02:21 +0300
Message-ID: <20080519220221.GC17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40105 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764522AbYESWE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 18:04:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes CVS keyword that weren't updated for a long time.

One of them was printed as part of a printk, which also doesn't make 
much sense for a 5 year old and no longer updated keyword.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/irda/donauboe.c   |    6 +-----
 drivers/net/irda/smsc-ircc2.c |    1 -
 drivers/net/irda/smsc-ircc2.h |    1 -
 3 files changed, 1 insertion(+), 7 deletions(-)

4898fd57aec7b22ced1a1472aa1736d43d587cc1 diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 1257e1a..34ad189 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -49,10 +49,6 @@
 /* Look at toshoboe.h (currently in include/net/irda) for details of */
 /* Where to get documentation on the chip         */
 
-
-static char *rcsid =
-  "$Id: donauboe.c V2.18 ven jan 10 03:14:16 2003$";
-
 /* See below for a description of the logic in this driver */
 
 /* User servicable parts */
@@ -1677,7 +1673,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
 
   pci_set_drvdata(pci_dev,self);
 
-  printk (KERN_INFO DRIVER_NAME ": Using multiple tasks, version %s\n", rcsid);
+  printk (KERN_INFO DRIVER_NAME ": Using multiple tasks\n");
 
   return 0;
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index cfe0194..78dc8e7 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1,5 +1,4 @@
 /*********************************************************************
- * $Id: smsc-ircc2.c,v 1.19.2.5 2002/10/27 11:34:26 dip Exp $
  *
  * Description:   Driver for the SMC Infrared Communications Controller
  * Status:        Experimental.
diff --git a/drivers/net/irda/smsc-ircc2.h b/drivers/net/irda/smsc-ircc2.h
index 0c36286..317b7fd 100644
--- a/drivers/net/irda/smsc-ircc2.h
+++ b/drivers/net/irda/smsc-ircc2.h
@@ -1,5 +1,4 @@
 /*********************************************************************
- * $Id: smsc-ircc2.h,v 1.12.2.1 2002/10/27 10:52:37 dip Exp $
  *
  * Description:   Definitions for the SMC IrCC chipset
  * Status:        Experimental.

