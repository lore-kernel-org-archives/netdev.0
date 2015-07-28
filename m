From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] Drivers: isdn: Drop unnecessary continue
Date: Tue, 28 Jul 2015 09:28:20 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1507280927500.2343@hadrien>
References: <1438067766-6438-1-git-send-email-shraddha.6596@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shraddha Barke <shraddha.6596@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438067766-6438-1-git-send-email-shraddha.6596@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



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
>  drivers/isdn/hardware/mISDN/hfcsusb.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
> index 114f3bc..34e4b6c 100644
> --- a/drivers/isdn/hardware/mISDN/hfcsusb.c
> +++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
> @@ -1923,7 +1923,6 @@ hfcsusb_probe(struct usb_interface *intf, const struct usb_device_id *id)
>  		    (le16_to_cpu(dev->descriptor.idProduct)
>  		     == hfcsusb_idtab[i].idProduct)) {
>  			vend_idx = i;
> -			continue;

Now there is only one statement in the branch, so the {} should go as
well.

julia

>  		}
>  	}
>
> --
> 2.1.0
>
>
