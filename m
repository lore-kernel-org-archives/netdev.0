From: Ralf Baechle <ralf@linux-mips.org>
Subject: [SLHC 4/4] Remove useless #ifdef MODULE stuff and printout
Date: Thu, 13 Jul 2006 12:14:55 +0100
Message-ID: <20060713111455.GB20095@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:41098 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750905AbWGMLOz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 07:14:55 -0400
Received: from localhost.localdomain ([127.0.0.1]:175 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133637AbWGMLOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 12:14:54 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of the MODULE stuff.  Could have rewritten to use modern interfaces
but the copyright message of this BSD licensed code isn't interesting enough
to be watched on every bootup, in every syslog.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/net/slhc.c |   14 --------------
 1 file changed, 14 deletions(-)

Index: linux-net/drivers/net/slhc.c
===================================================================
--- linux-net.orig/drivers/net/slhc.c	2006-07-10 01:35:56.000000000 +0100
+++ linux-net/drivers/net/slhc.c	2006-07-10 01:36:04.000000000 +0100
@@ -696,20 +696,6 @@ EXPORT_SYMBOL(slhc_compress);
 EXPORT_SYMBOL(slhc_uncompress);
 EXPORT_SYMBOL(slhc_toss);
 
-#ifdef MODULE
-
-int init_module(void)
-{
-	printk(KERN_INFO "CSLIP: code copyright 1989 Regents of the University of California\n");
-	return 0;
-}
-
-void cleanup_module(void)
-{
-	return;
-}
-
-#endif /* MODULE */
 #else /* CONFIG_INET */
 
 
