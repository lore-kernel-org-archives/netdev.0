From: Kumar Gala <galak@somerset.sps.mot.com>
Subject: [PATCH][netdrv gianfar] fix printk output
Date: Tue, 24 Aug 2004 13:33:31 -0500 (CDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0408241329260.22219-100000@blarg.somerset.sps.mot.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268175AbUHXSdi@vger.kernel.org>
To: akpm@osdl.org, <jgarzik@pobox.com>
List-Id: netdev.vger.kernel.org

Andrew,

Fix usage of printk on the output of mac address.

Signed-off-by: Kumar Gala <kumar.gala@freescale.com>

--

diff -Nru a/drivers/net/gianfar.c b/drivers/net/gianfar.c
--- a/drivers/net/gianfar.c	2004-08-24 13:28:18 -05:00
+++ b/drivers/net/gianfar.c	2004-08-24 13:28:18 -05:00
@@ -307,8 +307,8 @@
 	/* Print out the device info */
 	printk(KERN_INFO DEVICE_NAME, dev->name);
 	for (idx = 0; idx < 6; idx++)
-		printk(KERN_INFO "%2.2x%c", dev->dev_addr[idx], idx == 5 ? ' ' : ':');
-	printk(KERN_INFO "\n");
+		printk("%2.2x%c", dev->dev_addr[idx], idx == 5 ? ' ' : ':');
+	printk("\n");
 
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks.  Since this is global for all */
