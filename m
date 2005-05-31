From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12-rcx networking oops
Date: Tue, 31 May 2005 16:28:37 -0700
Message-ID: <20050531162837.4a110b29.akpm@osdl.org>
References: <20050531224012.GA16789@linuxace.com>
	<20050531161220.4af50a69.akpm@osdl.org>
	<20050531232326.GA17289@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
In-Reply-To: <20050531232326.GA17289@linuxace.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Phil Oester <kernel@linuxace.com> wrote:
>
> On Tue, May 31, 2005 at 04:12:20PM -0700, Andrew Morton wrote:
> > Are you _sure_ the hardware is good?
> 
> Well, it lasts on 2.6.10 indefinitely (since 1/1/5 minus the recent
> upgrade attempts).  And the hardware itself has been in service for
> a few years without failure.  It will last on 2.6.11 or 12-rc over
> the weekend fine, but as soon as traffic picks up during the workday
> it keels over.

hm, OK.  So I assume the machine has recently been running 2.6.10.  So it's
unlikely to be a hardware problem.

> > Are you running anything which would cause netdevs to be destroyed? 
> > Bringing virtual devices up and down?  TUN/TAP driver?  Bonding driver? 
> > Anything like that?
> 
> The box runs keepalived (for VRRP), and quagga (for OSPF).  Neither should
> be destroying netdevs during normal operation AFAIK.

OK.  It would need more than a very-ex-net person to work out how those
things affect the networking stack ;)

> > Have you tried CONFIG_DEBUG_SLAB and/or CONFIG_DEBUG_PAGEALLOC?
> 
> No - do you think it would reveal anything given the above?

It might catch the failure at an earlier stage.
