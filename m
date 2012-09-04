From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Tue, 4 Sep 2012 17:53:43 +0200
Message-ID: <20120904155343.GA2170@netboy.at.omicron.at>
References: <1346768514-19823-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62156 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756602Ab2IDPxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 11:53:49 -0400
Received: by bkwj10 with SMTP id j10so2726746bkw.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 08:53:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346768514-19823-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 04, 2012 at 04:21:54PM +0200, Oliver Neukum wrote:
> usbnet_start_xmit() is always called with a valid skb

So, has the problem that this test worked around been fixed?

Thanks,
Richard

 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> ---
>  drivers/net/usb/usbnet.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 8531c1c..5234d20 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1092,8 +1092,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>  	unsigned long		flags;
>  	int retval;
>  
> -	if (skb)
> -		skb_tx_timestamp(skb);
> +	skb_tx_timestamp(skb);
>  
>  	// some devices want funky USB-level framing, for
>  	// win32 driver (usually) and/or hardware quirks
> -- 
> 1.7.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
