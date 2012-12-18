From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 2/2] net: asix: handle packets crossing URB boundaries
Date: Tue, 18 Dec 2012 14:42:09 +0100
Message-ID: <2508574.zSdSI2h5LN@linux-lqwf.site>
References: <1355832626-3034-1-git-send-email-dev@lynxeye.de> <1355832626-3034-2-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Lucas Stach <dev@lynxeye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44823 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754739Ab2LRNlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 08:41:39 -0500
In-Reply-To: <1355832626-3034-2-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 December 2012 13:10:26 Lucas Stach wrote:
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -495,6 +495,10 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>                 dev->rx_urb_size = 2048;
>         }
>  
> +       dev->driver_priv = kzalloc(sizeof(struct asix_private), GFP_KERNEL);
> +       if (!dev->driver_priv)
> +               return -ENOMEM;
> +
>         return 0;

Where is this freed?

	Regards
		Oliver
