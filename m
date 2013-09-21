From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH 3/4] net: VSI: Add virtual station interface support
Date: Sat, 21 Sep 2013 10:30:29 -0700
Message-ID: <523DD7B5.2040206@intel.com>
References: <20130920231259.GA31479@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39802 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263Ab3IURab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Sep 2013 13:30:31 -0400
In-Reply-To: <20130920231259.GA31479@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/2013 4:12 PM, Neil Horman wrote:
>
> John-
>       Sorry for not copying your orgional patch into your email, but I apparently
> erased this email prior to fully reading it.  At any rate, as we discussed the
> other day, I think this idea is great, but it would benefit from being
> implemented using macvlans rather than a new link type.  If we can set a
> hardware flag in the underlying driver to indicate support for hardware
> forwarding, we can skip the macvlan soft forwarding, and just transmit directly.
> It should save us needing to create a whole new link type that is so simmilar to
> one we already have.
>
>       I'm back home now, so I can start looking at this if you like on monday.
>
> Best
> Neil
>
>

Yes definitely take a look making it an extension (flag) to macvlan
would be more useful if it can work. The one question I have is would
we need to clear the flag when a feature is attached to the PF that can
not be done in hardware. For example attaching an ingress qdisc,
ebtables, or starting up tcpdump are two that come to mind.

.John

Sorry for the duplication Neil, I sent this mail from a broken email
client just a minute ago and vger dropped it.
