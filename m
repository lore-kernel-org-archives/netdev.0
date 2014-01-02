From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] alx: add stats update function
Date: Thu, 2 Jan 2014 11:52:54 +0000
Message-ID: <1388663574.22017.8.camel@deadeye.wl.decadent.org.uk>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-4-git-send-email-sd@queasysnail.net>
	 <20140101215509.4a9f139c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>, <davem@davemloft.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22038 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaABLw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 06:52:57 -0500
In-Reply-To: <20140101215509.4a9f139c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-01 at 21:55 -0800, Stephen Hemminger wrote:
> On Thu,  2 Jan 2014 00:40:26 +0100
> Sabrina Dubroca <sd@queasysnail.net> wrote:
> 
> > diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
> > index 207bcc6..97e8731 100644
> > --- a/drivers/net/ethernet/atheros/alx/hw.h
> > +++ b/drivers/net/ethernet/atheros/alx/hw.h
> > @@ -482,6 +482,8 @@ struct alx_hw {
> >  
> >  	/* PHY link patch flag */
> >  	bool lnk_patch;
> > +
> > +	struct alx_hw_stats stats;
> >  };
> 
> Why do you need this to be part of the hw struct?
> It doesn't need to be persistent.
> couldn't the callers just pass it on the stack.

Oh come on, how is that going to work when the hardware counters are
read-to-clear?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
