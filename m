From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] remove bogus exports in ppp
Date: Tue, 16 Nov 2004 22:45:35 +1100
Message-ID: <16793.59487.473584.552366@cargo.ozlabs.ibm.com>
References: <20041024132504.GC19927@lst.de>
	<20041116083522.GA2356@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041116083522.GA2356@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig writes:

> ping?
> 
> --- 1.50/drivers/net/ppp_generic.c	2004-08-29 07:49:19 +02:00
> +++ edited/drivers/net/ppp_generic.c	2004-10-23 14:08:17 +02:00
> @@ -2721,8 +2721,6 @@
>  EXPORT_SYMBOL(ppp_output_wakeup);
>  EXPORT_SYMBOL(ppp_register_compressor);
>  EXPORT_SYMBOL(ppp_unregister_compressor);
> -EXPORT_SYMBOL(all_ppp_units); /* for debugging */
> -EXPORT_SYMBOL(all_channels); /* for debugging */
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS_CHARDEV_MAJOR(PPP_MAJOR);
>  MODULE_ALIAS("/dev/ppp");

Acked-by: Paul Mackerras <paulus@samba.org>
