From: Simon Kirby <sim@hostway.ca>
Subject: Re: ipv6 hitting route max_size
Date: Mon, 6 Jun 2011 16:15:21 -0700
Message-ID: <20110606231521.GB22559@hostway.ca>
References: <20110606213727.GB11757@hostway.ca> <20110606.150142.2071869702137894615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:43829 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab1FFXPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 19:15:22 -0400
Content-Disposition: inline
In-Reply-To: <20110606.150142.2071869702137894615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 03:01:42PM -0700, David Miller wrote:

> From: Simon Kirby <sim@hostway.ca>
> Date: Mon, 6 Jun 2011 14:37:27 -0700
> 
> > /proc/sys/net/ipv6/route/max_size and a number of similar GC knobs exist,
> > but max_size seems to limit the size of the v6 route table, not the v6
> > route cache.
> 
> There is no v6 route cache.
> 
> Instead of a routing cache, ipv6 route lookups "clone" new routes into
> the same datastructre the route table is stored in.

Ok, makes sense, but the result is now that ipv4 loads a full Internet
table with no adjustments, while ipv6 does not. Would it make sense to
change 4096 to 1048576, or would it be better to count only clones of
the actual route or something along those lines?

Simon-
