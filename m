From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch 2/6] 2.6.18: sb1250-mac: Missing inclusions from <linux/phy.h>
Date: Tue, 3 Oct 2006 16:18:28 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610031504580.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:15 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964844AbWJCPS2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:18:28 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 The <linux/phy.h> uses some types and macros defined in 
<linux/ethtool.h>, <linux/mii.h>, <linux/timer.h> and <linux/workqueue.h>, 
but fails to include these headers.

 Please consider.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-mips-2.6.18-20060920-include-phy-16
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/linux/phy.h linux-mips-2.6.18-20060920/include/linux/phy.h
--- linux-mips-2.6.18-20060920.macro/include/linux/phy.h	2006-08-29 04:58:59.000000000 +0000
+++ linux-mips-2.6.18-20060920/include/linux/phy.h	2006-10-03 14:18:05.000000000 +0000
@@ -20,6 +20,10 @@
 
 #include <linux/spinlock.h>
 #include <linux/device.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
 
 #define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
 				 SUPPORTED_10baseT_Full | \
