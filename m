From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Thu, 18 Dec 2008 20:25:27 -0500
Message-ID: <20081219012527.GA2669@localhost.localdomain>
References: <20081217211628.GD7356@hmsreliant.think-freely.org> <20081217133131.44a4f67f@extreme> <20081218011306.GA32191@hmsreliant.think-freely.org> <20081217.192936.169928910.davem@davemloft.net> <20081218195236.GA5191@hmsreliant.think-freely.org> <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48824 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbYLSB1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 20:27:38 -0500
Content-Disposition: inline
In-Reply-To: <1229640015.2914.20.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 10:40:15PM +0000, Ben Hutchings wrote:
> On Thu, 2008-12-18 at 14:52 -0500, Neil Horman wrote:
> [...]
> > diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> > index 086629c..75273bb 100644
> > --- a/drivers/net/sfc/efx.c
> > +++ b/drivers/net/sfc/efx.c
> > @@ -226,11 +226,11 @@ static int efx_poll(struct napi_struct *napi, int budget)
> >  
> >  	if (rx_packets < budget) {
> >  		/* There is no race here; although napi_disable() will
> > -		 * only wait for netif_rx_complete(), this isn't a problem
> > +		 * only wait for netif_rx_complete(this isn't a problem
> >  		 * since efx_channel_processed() will have no effect if
> >  		 * interrupts have already been disabled.
> >  		 */
> [...]
> 
> You'll want to exclude comments from your search-and-replace.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
> 

Dave, can you fix this up, or would you rather I repost the patch?
Neil

