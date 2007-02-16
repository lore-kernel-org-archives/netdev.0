From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: MediaGX/GeodeGX1 requires X86_OOSTORE. (Was: Re: Strange connection slowdown on pcnet32)
Date: Fri, 16 Feb 2007 17:48:24 -0500
Message-ID: <20070216224824.GG7585@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net> <20070216172110.GC7582@csclub.uwaterloo.ca> <20070216202300.GD7585@csclub.uwaterloo.ca> <20070216210157.GE7585@csclub.uwaterloo.ca> <20070216222728.GF7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Len Sorensen <lsorense@csclub.uwaterloo.ca>
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:59050 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566AbXBPWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 17:48:25 -0500
Content-Disposition: inline
In-Reply-To: <20070216222728.GF7585@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 05:27:28PM -0500, Lennart Sorensen wrote:
> On Fri, Feb 16, 2007 at 04:01:57PM -0500, Lennart Sorensen wrote:
> > It seems whenever it gets stuck, it is always the same descripter it is
> > stuck on.  Here is my current log:
> > 
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0433, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0433, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0433, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0340
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: 0310 next->status: 0340
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: pcnet32_poll: pcnet32_rx() got 16 packets
> > eth1: base: 0x05215812 status: 0310 next->status: 0310
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: netif_receive_skb(skb)
> > eth1: pcnet32_poll: pcnet32_rx() got 16 packets
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x6f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0033, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > eth1: interrupt  csr0=0x4f3 new csr=0x33, csr3=0x0000.
> > eth1: exiting interrupt, csr0=0x0433, csr3=0x5f00.
> > eth1: base: 0x04c51812 status: ffff8000 next->status: 0310
> > eth1: pcnet32_poll: pcnet32_rx() got 0 packets
> > 
> > So somehow it ends up that when it reads the status of the descriptor at
> > address 0x04c51812, it sees the status as 0x8000 (which means owned by
> > the MAC I believe), even though the next descriptor in the ring has a
> > sensible status, indicating that the descriptor is ready to be handled
> > by the driver.  Since the descriptor isn't ready, we exit without
> > handling anything and NAPI reschedules is the next time we get an
> > interrupt, and after some random number of tries, we finally see the
> > right status and handle the packet, along with a bunch of other packets
> > waiting in the descriptor ring.  Then we seem to hit the exact same
> > descriptor address again, with the same problem in the status we read,
> > and again we are stuck for a while, until finally we see the right
> > status, and another pile of packets get handled, and we again hit the
> > same descriptor address and get stuck.
> > 
> > I believe doing ifconfig eth1 down;ifconfig eth1 up actually
> > reinitialized the port with a new descriptor ring, but I could have got
> > that part wrong looking at the code.  Either way it clears things up
> > again for a while, until we get stuck again.
> > 
> > It makes me think the cpu somehow reads the memory location when the
> > descriptor ring is empty, notes it is owned by the MAC, and stops
> > handling packets (as it should), but then when the next receive occours,
> > it doesn't read physical memory again for some odd reason, and see the
> > previous status rather than the updated status.
> > 
> > Now for some reason it seems when the driver is not using NAPI, and
> > hence not enabling and disabling interrupt masks, this problem somehow
> > never occours (well at least I haven't managed to make it occour yet, so
> > who knows for sure.  Certainly with NAPI enabled I can kill it in
> > seconds).
> > 
> > Is there a way I can flush the CPU cache and force it to reread memory
> > for an address range, or for all cache, or some other way to ensure the
> > memory value I see is really the memory value that is in system memory
> > for a given address?
> 
> It seems so far that if I change Kconfig.cpu and force it to enable
> X86_OOSTORE for the MGEODE_GX1 then things behave properly.  Perhaps the
> out of order memory access crap the MediaGX/Geode processors do is
> having some affect, and enabling the code for wmb, etc, actually does
> something.

Well so far it really looks like enabling OOSTORE on the Geode
SC1200/GX1 really does make a difference.  A bit of searching seems to
indicate the person that originally submitted the patch that enabled
load/store reordering on the MediaGX/Geode though it might need OOSTORE,
but was convinced by others it didn't.  Looks like it really does need
it.  The failure that occoured before within a few seconds of starting a
large transfer, no longer fails and all I did was enable
CONFIG_X86_OOSTORE, and recompile pcnet32.ko and load the new module on
the running system.  Moving back to the pcnet32.ko built without OOSTORE
enabled hits the failure again within seconds, until ifconfig eth1
down/up reinitialized it's descriptor ring, after which it survices
another bit of transfer and then fails again.

I hate this CPU.

--
Len Sorensen
