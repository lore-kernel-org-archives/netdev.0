From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
Date: Fri, 11 May 2012 16:45:40 +0100
Message-ID: <20120511154540.GV11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <20120511.010445.1020972261904383892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de,
	a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20120511.010445.1020972261904383892.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2012 at 01:04:45AM -0400, David Miller wrote:
> 
> Ok, I'm generally happy with the networking parts.
> 

Great!

> If you address my feedback I'll sign off on it.
> 

I didn't get through all the feedback and respond today but I will
during next week, get it retested and reposted. Thanks a lot.

> The next question is whose tree this stuff goes through :-)

Yep, that's going to be entertaining.  I had structured this so it could
go through multiple trees but it's not perfect. If I switch patches 14
(slab-related) and 15 (network related), then it becomes

Patch 1 gets dropped after the next merge window as it'll be in mainline anyway
Patch 2-3 goes through Pekka's sl*b tree
Patch 4-7 goes through akpm
Patch 8-14 goes through linux-net
Patch 15-17 goes through akpm

That sort of multiple staging is messy though and correctness would depend
on what order linux-next pulls trees from. I think I should be able to
move 15-17 before linux-net which might simplify things a little although
that would be a bit odd from a bisection perspective.

>From my point of view, the ideal would be that all the patches go through
akpm's tree or yours but that probably will cause merge difficulties.

Any recommendations?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
