From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 02:34:39 -0700
Message-ID: <20081026023439.c6cf4e94.akpm@linux-foundation.org>
References: <20081024.221653.23695396.davem@davemloft.net>
	<1224914333.3822.18.camel@marge.simson.net>
	<1224917623.4929.15.camel@marge.simson.net>
	<20081025.002420.82739316.davem@davemloft.net>
	<Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	<1225010790.8566.22.camel@marge.simson.net>
	<1225011648.27415.4.camel@twins>
	<20081026021153.47878580.akpm@linux-foundation.org>
	<20081026092722.GA24799@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>, Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39619 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbYJZJfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 05:35:08 -0400
In-Reply-To: <20081026092722.GA24799@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008 12:27:22 +0300 Evgeniy Polyakov <zbr@ioremap.net> wrote:

> Hi.
> 
> On Sun, Oct 26, 2008 at 02:11:53AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > Andrew said recently:
> > >   "dbench is pretty chaotic and it could be that a good change causes
> > > dbench to get worse.  That's happened plenty of times in the past."
> > > 
> > > So I'm not inclined to worry too much about dbench in any way shape or
> > > form.
> > 
> > Well.  If there is a consistent change in dbench throughput, it is
> > important that we at least understand the reasons for it.  But we
> > don't necessarily want to optimise for dbench throughput.
> 
> Sorry, but such excuses do not deserve to be said. No matter how
> ugly, wrong, unusual or whatever else you might say about some test, but
> it shows the problem, which has to be fixed.

Not necessarily.  There are times when we have made changes which we
knew full well reduced dbench's throughput, because we believed them to
be of overall benefit.  I referred to one of them above.

> There is no 'dbench tune',
> there is fair number of problems, and at least several of them dbench
> already helped to narrow down and precisely locate. The same regressions
> were also observed in other benchmarks, originally reported before I
> started this thread.

You seem to be saying what I said.
