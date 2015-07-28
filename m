From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Drivers: isdn: Drop unnecessary continue
Date: Tue, 28 Jul 2015 12:18:09 +0200
Message-ID: <1438078689.20182.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438072868-5408-1-git-send-email-shraddha.6596@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shraddha Barke <shraddha.6596@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438072868-5408-1-git-send-email-shraddha.6596@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 14:11 +0530, Shraddha Barke wrote:
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
>  	}
>  
>  	printk(KERN_DEBUG


Well, it seems author intent was to use a break instead of a continue.

Not a big deal...
