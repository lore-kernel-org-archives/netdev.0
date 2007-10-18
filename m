From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [net] gianfar: remove orphan struct.
Date: Wed, 17 Oct 2007 20:21:13 -0400
Message-ID: <4716A6F9.8020206@garzik.org>
References: <E1Ii4k6-0000VM-0j@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49906 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758512AbXJRAVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:21:16 -0400
In-Reply-To: <E1Ii4k6-0000VM-0j@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Siewior wrote:
> struct net_device_stats is no longer used in driver's private
> struct but in struct net_device.
> 
> Cc: Li Yang <leoli@freescale.com>
> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
> ---
>  drivers/net/gianfar.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
> index c16cc8b..46cd773 100644
> --- a/drivers/net/gianfar.h
> +++ b/drivers/net/gianfar.h
> @@ -749,7 +749,6 @@ struct gfar_private {
>  	uint32_t msg_enable;
>  
>  	/* Network Statistics */
> -	struct net_device_stats stats;

applied


