From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 20:18:47 -0500
Message-ID: <1206667127.4122.94.camel@calx>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	 <1206645050.4849.77.camel@localhost>
	 <20080327.150456.39560267.davem@davemloft.net>
	 <1206663095.4122.82.camel@calx>  <1206665680.4849.137.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:47651 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbYC1BT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 21:19:59 -0400
In-Reply-To: <1206665680.4849.137.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-03-27 at 17:54 -0700, Joe Perches wrote:
> On Thu, 2008-03-27 at 19:11 -0500, Matt Mackall wrote:
> > In the 486 era, when CPU performance was close to 1:1 with memory,
> > branches were more expensive than sequential memory fetches, and
> > registers were scarce, inlining made a fair amount of sense.
> > 
> > But now we've moved very far away from that indeed:
> 
> Systems have certainly improved but Linux is used in a
> wide variety of CPU Hz, memory & register architectures.
> 
> Some of those systems haven't changed at all.

It's true. In particular, 486s haven't changed at all since the 486 era.
What's changed is that people no longer run 486s to go fast, they run
them to save money. Saving memory is a win for those people.

The same goes for embedded systems. Saving memory is much higher on the
priority scale than performance. And the fact that saving memory on the
low end aligns very nicely with increasing performance on the high end
means that's the direction we're going.

-- 
Mathematics is the supreme nostalgia of our time.

