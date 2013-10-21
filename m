From: Bob Tracy <rct@gherkin.frus.com>
Subject: Re: [BUG] 3.12.0-rcX IPv6 panic
Date: Mon, 21 Oct 2013 18:40:41 -0500
Message-ID: <20131021234041.GA12350@gherkin.frus.com>
References: <20131021131846.GA5769@gherkin.frus.com>
 <20131021155252.GA24158@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131021155252.GA24158@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 21, 2013 at 05:52:52PM +0200, Hannes Frederic Sowa wrote:
> On Mon, Oct 21, 2013 at 08:18:46AM -0500, Bob Tracy wrote:
> > Actually, a regression: the 3.11 kernel is rock-solid stable on my
> > Alpha.
> > 
> > Beginning with 3.12.0-rc1, I can reliably trigger a kernel panic by
> > executing the gogo6.net "gw6c" IPv6 client program.  If the networking
> > layer is active, an "Oops" will eventually (within a day) occur regardless
> > of whether I attempt to run "gw6c".  3.12.0-rcX is stable as long as I
> > leave networking completely disabled.  The error has persisted up through
> > -rc6.  Apologies for not mentioning this earlier, but the state of my
> > PWS-433au has been questionable, and I wanted to make sure I had a
> > legitimate bug sighting.
> > 
> > I'll have to transcribe the panic backtrace by hand: nothing makes it
> > into any of the system logs :-(.  I *can* recall that every backtrace
> > I've seen thus far has included one of the skb_copy() variants near the
> > top of the list (first or second function).
> 
> Try to capture the panic via serial console. Otherwise a picture
> would give us a first hint. Please watch out for lines like
> skb_(over|under)_panic.

I'll get a screen capture of some kind for you within the next day or
so.

> gw6c is a tunnel client? Can you post ip -6 tunnel ls?

Assuming you meant "show [NAME]" (no "ls" option for the tunnel object),
that yields the following with "gw6c" running on a 3.11.0 kernel:

smirkin:~# ip -6 tunnel show sit1
sit1: any/ipv6 remote 4056:5874:: local 4500:0:0:4000:4029:: encaplimit 0 hoplimit 0 tclass 0x00 flowlabel 0x00000 (flowinfo 0x00000000)

I'm running the gw6c client in gateway mode: the Alpha is my IPv6
gateway/firewall.

--Bob
