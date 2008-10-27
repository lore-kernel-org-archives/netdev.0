From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 10:29:17 +0100
Message-ID: <1225099757.9642.2.camel@marge.simson.net>
References: <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
	 <1224917623.4929.15.camel@marge.simson.net>
	 <20081025.002420.82739316.davem@davemloft.net>
	 <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
	 <1225010790.8566.22.camel@marge.simson.net>
	 <1225011648.27415.4.camel@twins>
	 <20081026021153.47878580.akpm@linux-foundation.org>
	 <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37859 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750965AbYJ0J3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 05:29:23 -0400
In-Reply-To: <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-10-26 at 20:03 +0100, Jiri Kosina wrote:
> On Sun, 26 Oct 2008, Andrew Morton wrote:
> 
> > > > > 208.4 MB/sec  -- vanilla 2.6.16.60
> > > > > 201.6 MB/sec  -- vanilla 2.6.20.1
> > > > > 172.9 MB/sec  -- vanilla 2.6.22.19
> > > > > 74.2 MB/sec   -- vanilla 2.6.23
> > > > >  46.1 MB/sec  -- vanilla 2.6.24.2
> > > > >  30.6 MB/sec  -- vanilla 2.6.26.1
> > > > > I.e. huge drop for 2.6.23 (this was with default configs for each 
> > > > > respective kernel).
> > Was this when we decreased the default value of
> > /proc/sys/vm/dirty_ratio, perhaps?  dbench is sensitive to that.
> 
> 2.6.28 gives 41.8 MB/s with /proc/sys/vm/dirty_ratio == 50. So small 
> improvement, but still far far away from the throughput of pre-2.6.23 
> kernels.

How many clients?

dbench 160 -t 60

2.6.28-smp (git.today)
Throughput 331.718 MB/sec 160 procs (no logjam)
Throughput 309.85 MB/sec 160 procs (contains logjam)
Throughput 392.746 MB/sec 160 procs (contains logjam)

	-Mike

