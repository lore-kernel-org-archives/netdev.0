From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/3] hso modem port detection fix patch
Date: Mon, 08 Dec 2008 02:54:47 -0800 (PST)
Message-ID: <20081208.025447.99306942.davem@davemloft.net>
References: <493CFAA9.6080401@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <493CFAA9.6080401-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Mon, 08 Dec 2008 11:44:57 +0100

Again, please CC: Alan for changes that might even remotely
be TTY layer related and thus he'd be interested in reviewing.

Thanks.

> This patch will clash with the previously posted.
> [PATCH 1/3] hso modem signals patch fix & should only
> be applied if the hso modem signals patch fix patch
> is not applied.
> 
> Fixed incorrect check for the modem port,
> Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> ---
> Index: netdev-2.6/drivers/net/usb/hso.c
> ===================================================================
> --- netdev-2.6.orig/drivers/net/usb/hso.c	2008-12-08 11:29:03.000000000 +0100
> +++ netdev-2.6/drivers/net/usb/hso.c	2008-12-08 11:30:00.000000000 +0100
> @@ -2343,7 +2343,7 @@
>  	serial->parent = hso_dev;
>  	hso_dev->port_data.dev_serial = serial;
>  
> -	if (port & HSO_PORT_MODEM)
> +	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM)
>  		num_urbs = 2;
>  	else
>  		num_urbs = 1;
> 
> 
> 
> -- 
> best regards,
> D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
