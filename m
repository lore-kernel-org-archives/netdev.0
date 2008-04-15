From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 09:08:31 -0700
Message-ID: <20080415160831.GB9704@kroah.com>
References: <20080414213238.GB28833@kroah.com> <200804151506.21856.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200804151506.21856.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2008 at 03:06:19PM +0200, Oliver Neukum wrote:
> --- linux-2.6.25-rc7-work/drivers/net/usb/hso.c.alt	2008-04-15 13:59:21.000000000 +0200
> +++ linux-2.6.25-rc7-work/drivers/net/usb/hso.c	2008-04-15 14:44:45.000000000 +0200
> @@ -220,6 +220,7 @@ struct hso_serial {
>  	unsigned long flags;
>  	u8 rts_state;
>  	u8 dtr_state;
> +	int tx_urb_used:1;

Bitfields should be "unsigned", I've changed this so sparse does not
complain.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
