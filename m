From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 8 Feb 2010 15:37:44 -0800
Message-ID: <20100208153744.236158aa.akpm@linux-foundation.org>
References: <1265639549.3048.33.camel@edumazet-laptop>
	<1265657560.4236.80.camel@edumazet-laptop>
	<20100208152606.91c55722.akpm@linux-foundation.org>
	<20100208.153406.123254133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38729 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780Ab0BHXhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:37:51 -0500
In-Reply-To: <20100208.153406.123254133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Feb 2010 15:34:06 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 8 Feb 2010 15:26:06 -0800
> 
> > I assume that this function spends most of its time walking over busy
> > entries?  Is a more powerful data structure needed?
> 
> When you're getting pounded with millions of packets per second,
> all mostly to different destinations (and thus resolving to
> different routing cache entries), this is what happens.
> 
> For a busy router, really, this is normal behavior.

Is the cache a net win in that scenario?
