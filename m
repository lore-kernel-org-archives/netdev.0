From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.6.0-test4][NET] sk_mca.c: fix linker error
Date: 23 Aug 2003 18:52:18 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061644938.2787.22.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch fixes the following linker error due to a typo:

*** Warning: "spin_lock_irqrestore" [drivers/net/sk_mca.ko] undefined!

--- linux-2.6.0-test4/drivers/net/sk_mca.c	2003-07-28 10:43:57.000000000 +0530
+++ linux-2.6.0-test4-nvk/drivers/net/sk_mca.c	2003-08-23 18:47:55.000000000 +0530
@@ -280,7 +280,7 @@
 
 	/* reenable interrupts */
 
-	spin_lock_irqrestore(&priv->lock, flags);
+	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 /* get LANCE register */
