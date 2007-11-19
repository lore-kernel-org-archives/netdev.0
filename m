From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 14/22] NET: DM9000: Remove unnecessary changelog in header comment
Date: Mon, 19 Nov 2007 20:39:24 +0000
Message-ID: <20071119204015.084862418@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61691 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751908AbXKSVSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:15 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-tidy-remove-changelog.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have a perfectly good version control system, so we do not
need to duplicate change comments in the header for this code.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt2/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt2.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt2/drivers/net/dm9000.c
@@ -1,7 +1,5 @@
 /*
- *   dm9000.c: Version 1.2 03/18/2003
- *
- *         A Davicom DM9000 ISA NIC fast Ethernet driver for Linux.
+ *      Davicom DM9000 Fast Ethernet driver for Linux.
  * 	Copyright (C) 1997  Sten Wang
  *
  * 	This program is free software; you can redistribute it and/or
@@ -14,44 +12,11 @@
  * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * 	GNU General Public License for more details.
  *
- *   (C)Copyright 1997-1998 DAVICOM Semiconductor,Inc. All Rights Reserved.
- *
- * V0.11	06/20/2001	REG_0A bit3=1, default enable BP with DA match
- * 	06/22/2001 	Support DM9801 progrmming
- * 	 	 	E3: R25 = ((R24 + NF) & 0x00ff) | 0xf000
- * 		 	E4: R25 = ((R24 + NF) & 0x00ff) | 0xc200
- * 		     		R17 = (R17 & 0xfff0) | NF + 3
- * 		 	E5: R25 = ((R24 + NF - 3) & 0x00ff) | 0xc200
- * 		     		R17 = (R17 & 0xfff0) | NF
- *
- * v1.00               	modify by simon 2001.9.5
- *                         change for kernel 2.4.x
- *
- * v1.1   11/09/2001      	fix force mode bug
- *
- * v1.2   03/18/2003       Weilun Huang <weilun_huang@davicom.com.tw>:
- * 			Fixed phy reset.
- * 			Added tx/rx 32 bit mode.
- * 			Cleaned up for kernel merge.
- *
- *        03/03/2004    Sascha Hauer <s.hauer@pengutronix.de>
- *                      Port to 2.6 kernel
- *
- *	  24-Sep-2004   Ben Dooks <ben@simtec.co.uk>
- *			Cleanup of code to remove ifdefs
- *			Allowed platform device data to influence access width
- *			Reformatting areas of code
- *
- *        17-Mar-2005   Sascha Hauer <s.hauer@pengutronix.de>
- *                      * removed 2.4 style module parameters
- *                      * removed removed unused stat counter and fixed
- *                        net_device_stats
- *                      * introduced tx_timeout function
- *                      * reworked locking
+ * (C) Copyright 1997-1998 DAVICOM Semiconductor,Inc. All Rights Reserved.
  *
- *	  01-Jul-2005   Ben Dooks <ben@simtec.co.uk>
- *			* fixed spinlock call without pointer
- *			* ensure spinlock is initialised
+ * Additional updates, Copyright:
+ *	Ben Dooks <ben@simtec.co.uk>
+ *	Sascha Hauer <s.hauer@pengutronix.de>
  */
 
 #include <linux/module.h>

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
