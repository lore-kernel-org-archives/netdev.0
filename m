From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] remove bogus exports in ppp
Date: Tue, 16 Nov 2004 09:35:22 +0100
Message-ID: <20041116083522.GA2356@lst.de>
References: <20041024132504.GC19927@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: paulus@samba.org
Content-Disposition: inline
In-Reply-To: <20041024132504.GC19927@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 24, 2004 at 03:25:04PM +0200, Christoph Hellwig wrote:
> even if they are usefull for debugging they're just bad namespace
> pollution for mainline

ping?

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
