From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH] remove bogus exports in ppp
Date: Fri, 28 Jan 2005 10:32:03 +1100
Message-ID: <16889.31219.724098.168789@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, hch@lst.de
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove unnecessary exports from ppp_generic.c.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Paul Mackerras <paulus@samba.org>

diff -urN linux-2.5/drivers/net/ppp_generic.c test/drivers/net/ppp_generic.c
--- linux-2.5/drivers/net/ppp_generic.c	2005-01-27 11:01:23.000000000 +1100
+++ test/drivers/net/ppp_generic.c	2005-01-28 10:23:54.539929344 +1100
@@ -2741,8 +2741,6 @@
 EXPORT_SYMBOL(ppp_output_wakeup);
 EXPORT_SYMBOL(ppp_register_compressor);
 EXPORT_SYMBOL(ppp_unregister_compressor);
-EXPORT_SYMBOL(all_ppp_units); /* for debugging */
-EXPORT_SYMBOL(all_channels); /* for debugging */
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV_MAJOR(PPP_MAJOR);
 MODULE_ALIAS("/dev/ppp");
