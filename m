From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/5] irnet: ppp: move IRNET_MINOR to
 include/linux/miscdevice.h
Date: Thu, 15 Dec 2016 03:54:06 -0800
Message-ID: <20161215115406.GA22905@kroah.com>
References: <20161215104250.16813-1-clabbe.montjoie@gmail.com>
 <20161215104250.16813-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, samuel@sortiz.org, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:51638 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757899AbcLOLx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 06:53:56 -0500
Content-Disposition: inline
In-Reply-To: <20161215104250.16813-3-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 11:42:48AM +0100, Corentin Labbe wrote:
> This patch move the define for IRNET_MINOR to include/linux/miscdevice.h
> It is better that all minor number definitions are in the same place.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  include/linux/miscdevice.h | 1 +
>  net/irda/irnet/irnet_ppp.h | 1 -
>  2 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
> index 18b2e3b..5ea0a65 100644
> --- a/include/linux/miscdevice.h
> +++ b/include/linux/miscdevice.h
> @@ -37,6 +37,7 @@
>  #define HWRNG_MINOR		183
>  #define MICROCODE_MINOR		184
>  #define KEYPAD_MINOR		185
> +#define IRNET_MINOR		187
>  #define D7S_MINOR		193
>  #define VFIO_MINOR		196
>  #define TUN_MINOR		200
> diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
> index 693ebc0..18fcead 100644
> --- a/net/irda/irnet/irnet_ppp.h
> +++ b/net/irda/irnet/irnet_ppp.h
> @@ -21,7 +21,6 @@
>  
>  /* /dev/irnet file constants */
>  #define IRNET_MAJOR	10	/* Misc range */
> -#define IRNET_MINOR	187	/* Official allocation */
>  
>  /* IrNET control channel stuff */
>  #define IRNET_MAX_COMMAND	256	/* Max length of a command line */
> -- 
> 2.10.2

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
