From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Fri, 28 Mar 2008 21:56:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803282134050.6616@wrl-59.cs.helsinki.fi>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206645050.4849.77.camel@localhost>  <20080327.150456.39560267.davem@davemloft.net>
  <1206663095.4122.82.camel@calx>  <1206665680.4849.137.camel@localhost>
 <1206667127.4122.94.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44736 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbYC1T5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 15:57:03 -0400
In-Reply-To: <1206667127.4122.94.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Mar 2008, Matt Mackall wrote:
> On Thu, 2008-03-27 at 17:54 -0700, Joe Perches wrote:
> > On Thu, 2008-03-27 at 19:11 -0500, Matt Mackall wrote:
> > > In the 486 era, when CPU performance was close to 1:1 with memory,
> > > branches were more expensive than sequential memory fetches, and
> > > registers were scarce, inlining made a fair amount of sense.
> > > 
> > > But now we've moved very far away from that indeed:
> > 
> > Systems have certainly improved but Linux is used in a
> > wide variety of CPU Hz, memory & register architectures.
> > 
> > Some of those systems haven't changed at all.
> 
> It's true. In particular, 486s haven't changed at all since the 486 era.
> What's changed is that people no longer run 486s to go fast, they run
> them to save money. Saving memory is a win for those people.

I'd guess though that they won't get that big size saving because they
probably have carefully tuned configs as well.

> The same goes for embedded systems. Saving memory is much higher on the
> priority scale than performance. And the fact that saving memory on the
> low end aligns very nicely with increasing performance on the high end
> means that's the direction we're going.

Also if some TLB misses are avoided due to uninlining, it may well 
rebalance the equation (each config & scenario is quite unique though).

-- 
 i.
