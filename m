From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove bogus exports in ppp
Date: Sun, 24 Oct 2004 15:25:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041024132504.GC19927@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: paulus@samba.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

even if they are usefull for debugging they're just bad namespace
pollution for mainline


--- 1.50/drivers/net/ppp_generic.c	2004-08-29 07:49:19 +02:00
+++ edited/drivers/net/ppp_generic.c	2004-10-23 14:08:17 +02:00
@@ -2721,8 +2721,6 @@
 EXPORT_SYMBOL(ppp_output_wakeup);
 EXPORT_SYMBOL(ppp_register_compressor);
 EXPORT_SYMBOL(ppp_unregister_compressor);
-EXPORT_SYMBOL(all_ppp_units); /* for debugging */
-EXPORT_SYMBOL(all_channels); /* for debugging */
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV_MAJOR(PPP_MAJOR);
 MODULE_ALIAS("/dev/ppp");
