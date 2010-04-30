From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: OFT - reserving CPU's for networking
Date: Fri, 30 Apr 2010 21:58:52 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004302150380.2951@localhost.localdomain>
References: <1272563772.2222.301.camel@edumazet-laptop> <20100429111047.031eeff9@nehalam> <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain> <20100430.115715.216750975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	ak@gargoyle.fritz.box, netdev@vger.kernel.org, andi@firstfloor.org,
	peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:48610 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759302Ab0D3T7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 15:59:15 -0400
In-Reply-To: <20100430.115715.216750975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

On Fri, 30 Apr 2010, David Miller wrote:

> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Thu, 29 Apr 2010 21:19:36 +0200 (CEST)
> 
> > Aside of that I seriously doubt that you can do networking w/o time
> > and timers.
> 
> You're right that we need timestamps and the like.
> 
> But only if we actually process the packets on these restricted cpus :-)
> 
> If we use RPS and farm out all packets to other cpus, ie. just doing
> the driver work and the remote cpu dispatch on these "offline" cpus,
> it is doable.
> 
> Then we can do cool tricks like having the cpu spin on a mwait() on the
> network device's status descriptor in memory.
> 
> In any event I agree with you, it's a cool idea at best, and likely
> not really practical.

Well, it might be worth to experiment with that once we get the basic
infrastructure in place to "isolate" cores under full kernel control. 

It's not too hard to solve the problems, but it seems nobody has a
free time slot to tackle them.

Thanks

	tglx
