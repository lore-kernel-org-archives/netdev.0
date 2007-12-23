From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 3/8] [PATCH] Use 1KB buffer in rndis_unbind
Date: Sat, 22 Dec 2007 16:51:11 -0800
Message-ID: <20071223005111.E699A230E0A@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <11983602953865-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jussi.kivilinna-E01nCVcF24I@public.gmane.org
To: bjd-a1rhEgazXTw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602953865-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From bjd-a1rhEgazXTw@public.gmane.org  Sat Dec 22 13:53:03 2007
> From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
> To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> 	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> Subject: [PATCH 3/8] [PATCH] Use 1KB buffer in rndis_unbind
> Date: Sat, 22 Dec 2007 22:51:29 +0100
>
> From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
>
> rndis_command requires the caller to pass in a buffer of at least 1KB.
>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

> ---
>  drivers/net/usb/rndis_host.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 96ef6a9..42b161c 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -577,7 +577,7 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
>  	struct rndis_halt	*halt;
>  
>  	/* try to clear any rndis state/activity (no i/o from stack!) */
> -	halt = kzalloc(sizeof *halt, GFP_KERNEL);
> +	halt = kzalloc(CONTROL_BUFFER_SIZE, GFP_KERNEL);
>  	if (halt) {
>  		halt->msg_type = RNDIS_MSG_HALT;
>  		halt->msg_len = ccpu2(sizeof *halt);
> -- 
> 1.5.2.5
>
