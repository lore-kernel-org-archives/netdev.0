From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cs89x0: fix warning release_irq label
Date: Sat, 13 Sep 2008 15:56:20 -0400
Message-ID: <48CC1AE4.60205@garzik.org>
References: <20080825233736.e7a17376.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52834 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068AbYIMT4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:56:24 -0400
In-Reply-To: <20080825233736.e7a17376.yoichi_yuasa@tripeaks.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yoichi Yuasa wrote:
> release_irq label is only used when ALLOW_DMA is defined.
> 
> drivers/net/cs89x0.c: In function 'net_open':
> drivers/net/cs89x0.c:1401: warning: label 'release_irq' defined but not used
> 
> Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
> 
> diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/net/cs89x0.c linux/drivers/net/cs89x0.c
> --- linux-orig/drivers/net/cs89x0.c	2008-08-07 13:14:59.904521743 +0900
> +++ linux/drivers/net/cs89x0.c	2008-08-07 16:11:31.469037245 +0900
> @@ -1397,9 +1397,7 @@ net_open(struct net_device *dev)
>  release_dma:
>  #if ALLOW_DMA
>  		free_dma(dev->dma);
> -#endif
>  release_irq:
> -#if ALLOW_DMA
>  		release_dma_buff(lp);
>  #endif

applied


