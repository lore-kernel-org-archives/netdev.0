From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Fri, 16 Nov 2012 21:27:34 +0000
Message-ID: <1353101254.2743.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121114231411.4328fc47@lola.kot>
	 <20121114.162956.610530798200803185.davem@davemloft.net>
	 <20121115010324.2707950c@lola.kot>
	 <20121114.180824.1930899985436392426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <kargig@void.gr>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37879 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab2KPV1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 16:27:37 -0500
In-Reply-To: <20121114.180824.1930899985436392426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-14 at 18:08 -0500, David Miller wrote:
> From: George Kargiotakis <kargig@void.gr>
> Date: Thu, 15 Nov 2012 01:03:24 +0200
> 
> > I think it's an issue that a LAN root user can disable a
> > locally enabled kernel "feature" for good. The kernel could provide a
> > somewhat more informative message on such an occasion taking place,
> > since it knows that max_addresses limit has been reached and it's not a
> > DAD failure.
> > 
> > My point is that I'd like the kernel to handle this situation a bit 
> > differently than it currently does.
> 
> Read my example again, it's the same thing for ipv4.
> 
> The root LAN user can disable all IPV4 communications to arbitrary IP
> addresses on the local LAN by emitting bogus ARP requests and
> poisoning everyone's caches.  What's the difference between that
> and this arbitrary ipv6 issue?
> 
> There is none at all.
> 
> If you have a root person on your local LAN you're subject to injection
> of bogus addressing and routing information.  This issue is not specific
> to ipv4 or ipv6 and is fundamental in nature.
> 
> So it is misleading to bring this up as an ipv6 specific problem, it's
> not.

You're quite right about this, but I think George's point may be that
it's harder to recover if and when the malicious traffic is stopped.
Poisoned ARP table entries will expire fairly quickly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
