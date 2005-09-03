From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv4/ipconfig.c should #include <linux/nfs_fs.h>
Date: Sat, 3 Sep 2005 03:25:43 +0200
Message-ID: <20050903012543.GE3657@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751346AbVICBZz@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every file should #include the header files containing the prototypes of 
it's global functions.

nfs_fs.h contains the prototype of root_nfs_parse_addr().


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-mm1-full/net/ipv4/ipconfig.c.old	2005-09-03 02:18:06.000000000 +0200
+++ linux-2.6.13-mm1-full/net/ipv4/ipconfig.c	2005-09-03 02:18:27.000000000 +0200
@@ -54,6 +54,7 @@
 #include <linux/major.h>
 #include <linux/root_dev.h>
 #include <linux/delay.h>
+#include <linux/nfs_fs.h>
 #include <net/arp.h>
 #include <net/ip.h>
 #include <net/ipconfig.h>
