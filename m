From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 01/14] Fix sparse warning: returning void-valued expression
Date: Thu, 24 Jan 2008 16:52:12 -0800
Message-ID: <200801241652.12357.david-b@pacbell.net>
References: <20080120001348.25718.36756.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080120001348.25718.36756.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> 
> rndis_unbind and usbnet_cdc_unbind don't return anything.
> 
> Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

> ---
> 
>  drivers/net/usb/rndis_host.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 1ebe325..96ef6a9 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -585,7 +585,7 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
>  		kfree(halt);
>  	}
>  
> -	return usbnet_cdc_unbind(dev, intf);
> +	usbnet_cdc_unbind(dev, intf);
>  }
>  
>  /*
> 
