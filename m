From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 09/14] [usbnet] add driver_priv pointer to 'struct usbnet'
Date: Thu, 24 Jan 2008 16:59:36 -0800
Message-ID: <200801241659.36850.david-b@pacbell.net>
References: <20080120001432.25718.30378.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080120001432.25718.30378.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Add a private data pointer to usbnet for rndis_wext module to use.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

> ---
> 
>  drivers/net/usb/usbnet.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
> index 29ab92e..0b4bf09 100644
> --- a/drivers/net/usb/usbnet.h
> +++ b/drivers/net/usb/usbnet.h
> @@ -31,6 +31,7 @@ struct usbnet {
>  	struct usb_interface	*intf;
>  	struct driver_info	*driver_info;
>  	const char		*driver_name;
> +	void			*driver_priv;
>  	wait_queue_head_t	*wait;
>  	struct mutex		phy_mutex;
>  	unsigned char		suspend_count;
> 
