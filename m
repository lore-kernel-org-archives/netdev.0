From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Regression: Bisected, IRQ and MSI allocations screwed without
 sparse irq
Date: Fri, 21 Nov 2008 13:11:43 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0811211307550.3179@localhost.localdomain>
References: <1226572171.6834.87.camel@localhost.localdomain>  <20081113.141513.116537651.davem@davemloft.net>  <Pine.LNX.4.64.0811192333130.30818@ask.diku.dk>  <20081119.151138.93409143.davem@davemloft.net>  <Pine.LNX.4.64.0811202035590.19962@ask.diku.dk>
 <alpine.LFD.2.00.0811201539360.3197@localhost.localdomain> <1227263614.25811.25.camel@localhost.localdomain> <alpine.LFD.2.00.0811210838360.3232@localhost.localdomain> <Pine.LNX.4.64.0811212022520.29808@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Ingo Molnar <mingo@elte.hu>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:49435 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbYKUVML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 16:12:11 -0500
In-Reply-To: <Pine.LNX.4.64.0811212022520.29808@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008, Jesper Dangaard Brouer wrote:
> > Ok, I queue it for mainline. This solves just the number of irqs
> > limitation, the rmmod problem still persists, right ?
> 
> It solves both the irq limit and the NIU driver unload bug.

I don't believe that it solves it. It hides it at the best.
 
> We should give it a good description.
> I have cooked up a patch with a description below, will you accept that?
> 
> Who's tree do you want it to go upsteam via?
> (You are listed as one of the X86 maintainers, but Ingo's tree seems more
> up-to-date. My patch below is agains DaveM's tree)

I queued it already with a description of the irq nr. problem. 

The rmmod problem is something different and should be investigated
thoroughly instead of declaring it solved by magic.
 
Thanks,

	tglx
