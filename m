From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mark arcnet_setup static
Date: Sun, 24 Oct 2004 15:18:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024131823.GC19658@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.19/drivers/net/arcnet/arcnet.c	2004-09-23 22:10:54 +02:00
+++ edited/drivers/net/arcnet/arcnet.c	2004-10-23 16:09:36 +02:00
@@ -91,7 +91,6 @@
 EXPORT_SYMBOL(arc_proto_null);
 EXPORT_SYMBOL(arcnet_unregister_proto);
 EXPORT_SYMBOL(arcnet_debug);
-EXPORT_SYMBOL(arcdev_setup);
 EXPORT_SYMBOL(alloc_arcdev);
 EXPORT_SYMBOL(arcnet_interrupt);
 
@@ -305,7 +304,7 @@
 
 
 /* Setup a struct device for ARCnet. */
-void arcdev_setup(struct net_device *dev)
+static void arcdev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_ARCNET;
 	dev->hard_header_len = sizeof(struct archdr);
