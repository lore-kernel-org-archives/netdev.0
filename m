From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (4/25) sk98: change #define to typedef
Date: Tue, 16 Nov 2004 08:22:54 +0000
Message-ID: <20041116082254.GA24321@infradead.org>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net> <20041115152203.24adb0ea@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041115152203.24adb0ea@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2004 at 03:22:03PM -0800, Stephen Hemminger wrote:
> Change #define of to a typedef.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
> --- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:28 -08:00
> +++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:28 -08:00
> @@ -106,7 +106,7 @@
>  #define SK_MAX_MACS		2
>  #define SK_MAX_NETS		2
>  
> -#define SK_IOC			char __iomem *
> +typedef void __iomem *SK_IOC;

Why do you need the typedef at all?  Just about every driver on the
planet is fine with a single void *__iomem iobase; in the per-device
structure
