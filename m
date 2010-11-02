From: Bandan Das <bandan.das@stratus.com>
Subject: Re: Routing over multiple interfaces
Date: Tue, 2 Nov 2010 14:47:32 -0400
Message-ID: <20101102184732.GC2077@stratus.com>
References: <1288645922.5977.41.camel@macbook.infradead.org>
 <20101101.141638.116372747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, uweber@astaro.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub5.stratus.com ([134.111.1.18]:43982 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab0KBSrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 14:47:46 -0400
Content-Disposition: inline
In-Reply-To: <20101101.141638.116372747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  0, David Miller <davem@davemloft.net> wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Mon, 01 Nov 2010 17:12:02 -0400
> 
> > But when I do a large upload, I find that the kernel is only ever using
> > a *single* link at a time, rather than both. How can I make it use
> > *both* links? It's fine to confine each flow to a single link if it
> > doesn't saturate that link... but once the queue is full, it should
> > overflow onto the other device.
> 
> Once a TCP socket gets a routing cache entry, that's what it uses
> for the rest of the life of the connection.
> 
> The multi-pathing decision happens at the time the routing
> cache entry is created.
> 
> What you want is multi-path routing support in the routing cache.
> 
> We used to have that, but the guy who implemented it (after bugging
> me to integrate it for 4 months straight, non-stop) just did a code
> dump and then disappeared and fixed none of the serious fundamental
> problems which existed in his code.

You are talking about the equalize patch, right ? 

I had a similar requirement once a long time back and I didn't 
know of any other way to do it, so, I just "forced" this patch 
on a 2.6.23 kernel.
David W, may be you can take a look just to get an idea..

http://th.oughts.org/equalize_2.6_0.3.patch

Bandan
