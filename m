From: David Miller <davem@davemloft.net>
Subject: Re: Linux kernel handling of IPv6 temporary addresses
Date: Wed, 14 Nov 2012 18:08:24 -0500 (EST)
Message-ID: <20121114.180824.1930899985436392426.davem@davemloft.net>
References: <20121114231411.4328fc47@lola.kot>
	<20121114.162956.610530798200803185.davem@davemloft.net>
	<20121115010324.2707950c@lola.kot>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kargig@void.gr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436Ab2KNXIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 18:08:25 -0500
In-Reply-To: <20121115010324.2707950c@lola.kot>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: George Kargiotakis <kargig@void.gr>
Date: Thu, 15 Nov 2012 01:03:24 +0200

> I think it's an issue that a LAN root user can disable a
> locally enabled kernel "feature" for good. The kernel could provide a
> somewhat more informative message on such an occasion taking place,
> since it knows that max_addresses limit has been reached and it's not a
> DAD failure.
> 
> My point is that I'd like the kernel to handle this situation a bit 
> differently than it currently does.

Read my example again, it's the same thing for ipv4.

The root LAN user can disable all IPV4 communications to arbitrary IP
addresses on the local LAN by emitting bogus ARP requests and
poisoning everyone's caches.  What's the difference between that
and this arbitrary ipv6 issue?

There is none at all.

If you have a root person on your local LAN you're subject to injection
of bogus addressing and routing information.  This issue is not specific
to ipv4 or ipv6 and is fundamental in nature.

So it is misleading to bring this up as an ipv6 specific problem, it's
not.
