From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: Fix printk
Date: Fri, 23 Nov 2007 21:03:00 -0500
Message-ID: <47478654.2060107@garzik.org>
References: <E1Iu9pB-0002xZ-5J@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41894 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521AbXKXCDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 21:03:02 -0500
In-Reply-To: <E1Iu9pB-0002xZ-5J@nanv.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> A printk in the error handling code of dm9601.c was missing a newline.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/dm9601.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
> index 2c68573..1ffdd10 100644
> --- a/drivers/net/usb/dm9601.c
> +++ b/drivers/net/usb/dm9601.c
> @@ -94,7 +94,7 @@ static void dm_write_async_callback(struct urb *urb)
>  	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
>  
>  	if (urb->status < 0)
> -		printk(KERN_DEBUG "dm_write_async_callback() failed with %d",
> +		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
>  		       urb->status);
>  

applied #upstream-fixes


