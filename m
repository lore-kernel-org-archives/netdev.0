From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet32:  remove compile warnings in non-napi mode
Date: Wed, 17 Oct 2007 20:22:06 -0400
Message-ID: <4716A72E.80600@garzik.org>
References: <1192662610.5312.1.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49959 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762483AbXJRAWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:22:08 -0400
In-Reply-To: <1192662610.5312.1.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Remove compile warning when in non-napi mode.
> 
> Signed-off-by:  Don Fry <pcnet32@verizon.net>
> ---
> --- linux-2.6.23-git7/drivers/net/napi.pcnet32.c	2007-10-17 15:56:15.000000000 -0700
> +++ linux-2.6.23-git7/drivers/net/pcnet32.c	2007-10-17 16:00:44.000000000 -0700
> @@ -442,7 +442,9 @@ static struct pcnet32_access pcnet32_dwi
>  
>  static void pcnet32_netif_stop(struct net_device *dev)
>  {
> +#ifdef CONFIG_PCNET32_NAPI
>  	struct pcnet32_private *lp = netdev_priv(dev);
> +#endif
>  	dev->trans_start = jiffies;
>  #ifdef CONFIG_PCNET32_NAPI
>  	napi_disable(&lp->napi);

applied


