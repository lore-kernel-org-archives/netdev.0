From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 3/4] net: VSI: Add virtual station interface support
Date: Sun, 22 Sep 2013 12:44:59 -0400
Message-ID: <20130922164458.GA2264@neilslaptop.think-freely.org>
References: <20130920231259.GA31479@neilslaptop.think-freely.org>
 <523DD7B5.2040206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60135 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab3IVQpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 12:45:22 -0400
Content-Disposition: inline
In-Reply-To: <523DD7B5.2040206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 10:30:29AM -0700, John Fastabend wrote:
> On 9/20/2013 4:12 PM, Neil Horman wrote:
> >
> >John-
> >      Sorry for not copying your orgional patch into your email, but I apparently
> >erased this email prior to fully reading it.  At any rate, as we discussed the
> >other day, I think this idea is great, but it would benefit from being
> >implemented using macvlans rather than a new link type.  If we can set a
> >hardware flag in the underlying driver to indicate support for hardware
> >forwarding, we can skip the macvlan soft forwarding, and just transmit directly.
> >It should save us needing to create a whole new link type that is so simmilar to
> >one we already have.
> >
> >      I'm back home now, so I can start looking at this if you like on monday.
> >
> >Best
> >Neil
> >
> >
> 
> Yes definitely take a look making it an extension (flag) to macvlan
> would be more useful if it can work. The one question I have is would
> we need to clear the flag when a feature is attached to the PF that can
> not be done in hardware. For example attaching an ingress qdisc,
> ebtables, or starting up tcpdump are two that come to mind.
> 
I think that it probably would, although I expect that this would be the case
independent of the implementations (virtual station interfaces vs. macvlans).
The only other option I see is to disallow those features that can't be done in
hardware, but I think thats unworkable long term.

Neil

> .John
> 
> Sorry for the duplication Neil, I sent this mail from a broken email
> client just a minute ago and vger dropped it.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
