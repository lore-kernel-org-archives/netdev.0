From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] hso: rfkill type should be WWAN
Date: Thu, 06 Nov 2008 00:43:05 -0500
Message-ID: <491283E9.6080006@garzik.org>
References: <20081104113230.3552.69802.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081104113230.3552.69802.stgit-QQDCe9+Z9hORTDQbGLh+0LCZl1fM7XKJHMZNOu17VRllET+NkH7nKV6hYfS7NtTn@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Paulius Zaleckas wrote:
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
> Cc: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> ---
> 
>  drivers/net/usb/hso.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 1164c52..3f49e83 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -2188,7 +2188,7 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
>  	char *rfkn;
>  
>  	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
> -				 RFKILL_TYPE_WLAN);
> +				 RFKILL_TYPE_WWAN);
>  	if (!hso_net->rfkill) {
>  		dev_err(dev, "%s - Out of memory", __func__);
>  		return;
> 

applied


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
