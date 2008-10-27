From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 15:17:16 +0100
Message-ID: <1225117036.4973.23.camel@marge.simson.net>
References: <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
	 <1224917623.4929.15.camel@marge.simson.net>
	 <20081025.002420.82739316.davem@davemloft.net>
	 <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	 <1225010790.8566.22.camel@marge.simson.net>
	 <1225011648.27415.4.camel@twins>
	 <20081026021153.47878580.akpm@linux-foundation.org>
	 <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
	 <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>
	 <20081027112750.GA2771@elte.hu>
	 <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
	 <1225109171.4238.23.camel@marge.simson.net>
	 <alpine.LNX.1.10.0810271441590.12928@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43323 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750747AbYJ0OR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 10:17:26 -0400
In-Reply-To: <alpine.LNX.1.10.0810271441590.12928@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 14:42 +0100, Jiri Kosina wrote:
> On Mon, 27 Oct 2008, Mike Galbraith wrote:
> 
> > > real world workloads. If your fairness hurts throughput that much maybe
> > > your scheduler algorithm is just plain *wrong* as it isn't adapting to
> > > workload at all well.
> > Doesn't seem to be scheduler/fairness.  2.6.22.19 is O(1), and falls
> > apart too, I posted the numbers and full dbench output yesterday.
> 
> We'll need to look into this a little bit more I think. I have sent out 
> some numbers too, and these indicate very clearly that there is more than 
> 50% performance drop (measured by dbench) just after the very merge of CFS 
> in 2.6.23-rc1 merge window.

Sure.  Watching the per/sec output, every kernel I have sucks at high
client count dbench, it's just a matter of how badly, and how long.

BTW, the nice pretty 160 client numbers I posted yesterday for ext2
turned out to be because somebody adds _netdev mount option when I mount
-a in order to mount my freshly hotplugged external drive (why?  that
ain't in my fstab).  Without that switch, ext2 output is roughly as
raggedy as ext3, and nowhere near the up to 1.4GB/sec I can get with
dirty_ratio=50 + ext2 + (buy none, get one free) _netdev option.  Free
for the not asking option does nada for ext3.

	-Mike

