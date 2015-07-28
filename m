From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] Drivers: isdn: Drop unnecessary continue
Date: Tue, 28 Jul 2015 10:47:39 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1507281046530.2343@hadrien>
References: <1438072868-5408-1-git-send-email-shraddha.6596@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shraddha Barke <shraddha.6596@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438072868-5408-1-git-send-email-shraddha.6596@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch should have v2 in the subject line, and should have a
description of the change since the previous version under the ---

On Tue, 28 Jul 2015, Shraddha Barke wrote:

> The semantic patch used to make this change is :
>
> @@
> @@
> for (...;...;...) {
>   ...
>   if (...) {
>     ...
> -   continue;
>   }
> }
>
> Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
> ---
>  drivers/isdn/hardware/mISDN/hfcsusb.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
> index 114f3bc..91beb83 100644
> --- a/drivers/isdn/hardware/mISDN/hfcsusb.c
> +++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
> @@ -1921,10 +1921,9 @@ hfcsusb_probe(struct usb_interface *intf, const struct usb_device_id *id)
>  		if ((le16_to_cpu(dev->descriptor.idVendor)
>  		     == hfcsusb_idtab[i].idVendor) &&
>  		    (le16_to_cpu(dev->descriptor.idProduct)
> -		     == hfcsusb_idtab[i].idProduct)) {
> +		     == hfcsusb_idtab[i].idProduct))
>  			vend_idx = i;
> -			continue;
> -		}
> +

There is no need to add a blank line here.

julia

>  	}
>
>  	printk(KERN_DEBUG
> --
> 2.1.0
>
>
