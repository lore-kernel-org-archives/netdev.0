From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 02:03:26 +0100
Message-ID: <1340154206.6871.90.camel@deadeye.wl.decadent.org.uk>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	 <1340151666.6871.81.camel@deadeye.wl.decadent.org.uk>
	 <20120619.175435.1705108432673390966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19936 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752073Ab2FTBDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 21:03:30 -0400
In-Reply-To: <20120619.175435.1705108432673390966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 17:54 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 20 Jun 2012 01:21:06 +0100
> 
> > This works only because MAX_INET_PROTOS is defined as 256, so that hash
> > == protocol.  If we were ever to change MAX_INET_PROTOS then we would
> > need to add a whole lot of protocol checks, but this isn't particularly
> > obvious!  Perhaps it would be better to remove the 'hashing' altogether?
> 
> We never have changed the value and we never will.

Well that's what I expected.

> The hash is perfect, what's the big deal?

It obscures what we're really doing and relying on.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
