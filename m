From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Tue, 28 Oct 2008 11:57:36 +0100
Message-ID: <1225191456.4903.254.camel@marge.simson.net>
References: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
	 <20081027183312.GD11494@elte.hu> <20081027193933.GB2590@ioremap.net>
	 <20081027.124848.163119274.davem@davemloft.net>
	 <1225189462.4903.238.camel@marge.simson.net>
	 <20081028103741.GA22319@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net,
	alan@lxorguk.ukuu.org.uk, jkosina@suse.cz,
	akpm@linux-foundation.org, a.p.zijlstra@chello.nl, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55953 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752135AbYJ1K5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 06:57:41 -0400
In-Reply-To: <20081028103741.GA22319@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 11:37 +0100, Ingo Molnar wrote:
> * Mike Galbraith <efault@gmx.de> wrote:
> 
> > ..removing the overhead from .27 does not produce the anticipated 
> > result despite a max context switch rate markedly above that of 
> > 2.6.26.
> > 
> > There lies an as yet unaddressed regression IMBHO.  The hrtick has 
> > been addressed.  It sucked at high frequency, and it's gone.  The 
> > added math overhead in .27 hurt some too, and is now history as 
> > well.
> 
> thanks Mike for the _extensive_ testing and bug hunting session you've 
> done in the past couple of weeks! All the relevant fixlets you found 
> are now queued up properly in sched/urgent, correct?

Yeah.

> What's your gut feeling, is that remaining small regression scheduler 
> or networking related?

I don't know where it lives.  I'm still looking, and the numbers are
still playing games with my head.

> i'm cutting the ball in half and i'm passing over one half of it to 
> the networking folks, because your numbers show _huge_ sensitivity in 
> this workload, depending on networking settings:

I strongly _suspect_ that the network folks have some things they could
investigate, but given my utter failure at finding the smoking gun, I
can't say one way of the other.  IMHO, sharing with network folks would
likely turn out to be a fair thing to do.

Am I waffling?  Me?  You bet your a$$! My clock is already squeaky clean
thank you very much :-)

What I can say is that my box is quite certain that there are influences
outside the scheduler which have more influence benchmark results than
the scheduler does through the life of testing.

	-Mike

