From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] [DM9000] Added support for big-endian hosts
Date: Sat, 25 Aug 2007 00:31:58 -0400
Message-ID: <46CFB0BE.4030301@garzik.org>
References: <200708161015.35337.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41678 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbXHYEcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:32:00 -0400
In-Reply-To: <200708161015.35337.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Pinchart wrote:
> This patch splits the receive status in 8bit wide fields and convert the
> packet length from little endian to CPU byte order.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/dm9000.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index c3de81b..a424810 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -894,7 +894,8 @@ dm9000_timer(unsigned long data)
>  }
>  
>  struct dm9000_rxhdr {
> -	u16	RxStatus;
> +	u8	RxPktReady;
> +	u8	RxStatus;
>  	u16	RxLen;
>  } __attribute__((__packed__));

why does this not need endian conversions as well?

	Jeff



