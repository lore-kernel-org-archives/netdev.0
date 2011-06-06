From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 hitting route max_size
Date: Mon, 06 Jun 2011 15:01:42 -0700 (PDT)
Message-ID: <20110606.150142.2071869702137894615.davem@davemloft.net>
References: <20110606213727.GB11757@hostway.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: sim@hostway.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab1FFWCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 18:02:46 -0400
In-Reply-To: <20110606213727.GB11757@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kirby <sim@hostway.ca>
Date: Mon, 6 Jun 2011 14:37:27 -0700

> /proc/sys/net/ipv6/route/max_size and a number of similar GC knobs exist,
> but max_size seems to limit the size of the v6 route table, not the v6
> route cache.

There is no v6 route cache.

Instead of a routing cache, ipv6 route lookups "clone" new routes into
the same datastructre the route table is stored in.

> Is this cache limit somehow tied to route entries by some (un)intentional
> IPv6 feature?

Again, there is no cache.  The same datastructure holds the routing table,
and cloned routes created by lookups.  There is no seperation.
