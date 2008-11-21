From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Regression: Bisected, IRQ and MSI allocations screwed without
 sparse irq
Date: Fri, 21 Nov 2008 08:40:47 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0811210838360.3232@localhost.localdomain>
References: <1226572171.6834.87.camel@localhost.localdomain>  <20081113.141513.116537651.davem@davemloft.net>  <Pine.LNX.4.64.0811192333130.30818@ask.diku.dk>  <20081119.151138.93409143.davem@davemloft.net>  <Pine.LNX.4.64.0811202035590.19962@ask.diku.dk>
 <alpine.LFD.2.00.0811201539360.3197@localhost.localdomain> <1227263614.25811.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:41500 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754141AbYKUQlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 11:41:04 -0500
In-Reply-To: <1227263614.25811.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008, Jesper Dangaard Brouer wrote:
> > Can you please try the attached patch ?
> 
> I have tried the patch and it solved the problem! :-)
> 
> I'll gladly test other patches from your.  Guess this patch needs to be
> brushed up before a mainline patch is ready.

Ok, I queue it for mainline. This solves just the number of irqs
limitation, the rmmod problem still persists, right ?

Thanks,

	tglx


