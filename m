From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] unexport ei_tx_timeout
Date: Sun, 24 Oct 2004 15:12:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024131256.GC19567@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

not used by any module, and the API doesn't make sense as export either


--- 1.24/drivers/net/8390.c	2004-10-20 10:37:15 +02:00
+++ edited/drivers/net/8390.c	2004-10-23 16:17:41 +02:00
@@ -1114,7 +1114,6 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 EXPORT_SYMBOL(ei_poll);
 #endif
-EXPORT_SYMBOL(ei_tx_timeout);
 EXPORT_SYMBOL(NS8390_init);
 EXPORT_SYMBOL(__alloc_ei_netdev);
 
