From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 12:48:48 -0700 (PDT)
Message-ID: <20081027.124848.163119274.davem@davemloft.net>
References: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
	<20081027183312.GD11494@elte.hu>
	<20081027193933.GB2590@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, alan@lxorguk.ukuu.org.uk, jkosina@suse.cz,
	akpm@linux-foundation.org, a.p.zijlstra@chello.nl, efault@gmx.de,
	rjw@sisk.pl, s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752519AbYJ0TtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 15:49:11 -0400
In-Reply-To: <20081027193933.GB2590@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Mon, 27 Oct 2008 22:39:34 +0300

> On Mon, Oct 27, 2008 at 07:33:12PM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> > The moment there's real IO it becomes harder to analyze but the same 
> > basic behavior remains: the more unfair the IO scheduler, the "better" 
> > dbench results we get.
> 
> Right now there is no disk IO at all. Only quite usual network and
> process load.

I think the hope is that by saying there isn't a problem enough times,
it will become truth. :-)

More seriously, Ingo, what in the world do we need to do in order to get
you to start doing tbench runs and optimizing things (read as: fixing
the regression you added)?

I'm personally working on a test fibonacci heap implementation for
the fair sched code, and I already did all of the cost analysis all
the way back to the 2.6.22 pre-CFS days.

But I'm NOT a scheduler developer, so it isn't my responsibility to do
this crap for you.  You added this regression, why do I have to get my
hands dirty in order for there to be some hope that these regressions
start to get fixed?
