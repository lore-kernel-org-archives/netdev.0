From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 13:35:43 -0400
Message-ID: <20100316173543.GA13529@hmsreliant.think-freely.org>
References: <201003161407.51925.vgusev@openvz.org>
 <20100316143437.GA8225@hmsreliant.think-freely.org>
 <201003161827.08595.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53011 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938018Ab0CPRfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 13:35:52 -0400
Content-Disposition: inline
In-Reply-To: <201003161827.08595.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 16, 2010 at 06:27:08PM +0300, Vitaliy Gusev wrote:
> On Tuesday 16 March 2010 05:34:37 pm Neil Horman wrote:
> ...
> > Yeah, this seems reasonable.  Although this might be a good time to bring up the
> > subject of deprecating or removing the secret interval.  We've had our
> > statistical analysis bits in place to drive the rebuilding of the cache in the
> > event that any one chain gets too long, and in the year or so that we've had it,
> > it seems we've shaken out a few bugs with it (which suggests that people are
> > using it routinely).  As such, might it be time to just drop the rebuild timer
> > in its entirety?
> 
> Rebuild timer was introduced by secure reason when there was no analysis for
> chain lenght. Now it seems that rebuild timer can be removed.
> 
Dave, Eric, Herbert, what are your opinions on this?  Is the statistical analysis code
mature enough at this point to warrant the removal of the rebuild timer, or
should we still keep it as a fallback mechanism?
Neil

> 
> > 
> > Until that decision is made of course, the above seems like a sane fix for it.
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > 
> 
> 
> 
> Thanks,
> Vitaliy Gusev
> 
