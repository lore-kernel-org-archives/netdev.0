From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/5] alx: add alx_get_stats operation
Date: Thu, 2 Jan 2014 11:57:47 +0000
Message-ID: <1388663867.22017.13.camel@deadeye.wl.decadent.org.uk>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-5-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22093 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaABL5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 06:57:51 -0500
In-Reply-To: <1388619628-3373-5-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:
[...]
> --- a/drivers/net/ethernet/atheros/alx/main.c
> +++ b/drivers/net/ethernet/atheros/alx/main.c
> @@ -1166,10 +1166,54 @@ static void alx_poll_controller(struct net_device *netdev)
>  }
>  #endif
>  
> +static struct net_device_stats *alx_get_stats(struct net_device *netdev)
[...]
>  static const struct net_device_ops alx_netdev_ops = {
>  	.ndo_open               = alx_open,
>  	.ndo_stop               = alx_stop,
>  	.ndo_start_xmit         = alx_start_xmit,
> +	.ndo_get_stats          = alx_get_stats,
[...]

You should implement ndo_get_stats64 rather than ndo_get_stats.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
