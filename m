From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH] fix arm/etherh.c allocation
Date: Tue, 20 Apr 2004 20:49:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404202049.09130.daniel.ritz@gmx.ch>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Russell King <rmk+lkml@arm.linux.org.uk>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

russell, there's a part of my original patch you missed: allocation of the
netdevice. doesn't need a comment.

against 2.6-bknow

rgds
-daniel 


--- 1.23/drivers/net/arm/etherh.c	Wed Apr 14 12:23:55 2004
+++ edited/etherh.c	Tue Apr 20 20:39:04 2004
@@ -574,7 +574,7 @@
 	if (ret)
 		goto out;
 
-	dev = alloc_ei_netdev();
+	dev = __alloc_ei_netdev(sizeof(struct etherh_priv));
 	if (!dev) {
 		ret = -ENOMEM;
 		goto release;
