From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Minimizing TCP latency
Date: Mon, 29 Mar 2010 16:23:49 +0100
Message-ID: <1269876229.2092.3.camel@achroite.uk.solarflarecom.com>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
	 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hoyt <benhoyt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40740 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0C2PXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 11:23:52 -0400
In-Reply-To: <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-03-29 at 16:24 +1300, Ben Hoyt wrote:
> > I'm happy to receive some pointers via this list [...]
> 
> Sorry, I should also have posted more about what I've done in terms of
> reducing latency so far:
> 
> * We've already got TCP_NODELAY activated.
> 
> * We've also turned off interrupt coalescing on the network card (for
> example, see http://www.29west.com/docs/THPM/latency-interrupt-coalescing.html).
> 
> * We've modified our process's CPU affinity so it runs on a core by
> itself, reducing interrupt-handling latency slightly further.
> 
> * Our code is written in C, and we've tried to keep it as close to the
> kernel's socket calls as possible.
> 
> So we're currently looking further into ways to reduce latency, which
> currently looks like it'll mean digging deeper into the kernel's
> networking options and innards.

Choose low-latency NICs.  Read the tuning guide, but run your own
benchmarks.

> FYI, we're using RHE release 4 and kernel version 2.6.9 on x86_64 machines.

You're not going to get much help here in working on that kernel.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

