From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 4/8] ipg: remove driver version
Date: Fri, 23 Nov 2007 10:19:21 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231018550.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbXKWITW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:19:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

The driver is in mainline now so there's no need to maintain a separate version
number.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |    3 +--
 drivers/net/ipg.h |    2 --
 2 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -51,8 +51,7 @@ enum {
 #define DRV_NAME	"ipg"
 
 MODULE_AUTHOR("IC Plus Corp. 2003");
-MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
-		   DrvVer);
+MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver");
 MODULE_LICENSE("GPL");
 
 //variable record -- index by leading revision/length
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -25,8 +25,6 @@
 #include <asm/bitops.h>
 /*#include <asm/spinlock.h>*/
 
-#define DrvVer "2.09d"
-
 /*
  *	Constants
  */
