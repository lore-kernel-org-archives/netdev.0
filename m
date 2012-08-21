From: Mel Gorman <mgorman@suse.de>
Subject: Re: regression with poll(2)
Date: Tue, 21 Aug 2012 08:05:15 +0100
Message-ID: <20120821070515.GA1657@suse.de>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
 <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
 <20120820090443.GA3275@suse.de>
 <alpine.DEB.2.00.1208200930510.26904@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu,
	emunson@mgebm.net, eric.dumazet@gmail.com, sebastian@breakpoint.cc,
	cl@linux.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Sage Weil <sage@inktank.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1208200930510.26904@cobra.newdream.net>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 20, 2012 at 09:54:59AM -0700, Sage Weil wrote:
> > <SNIP>
> > 
> > > I've retested several times and confirmed that this change leads to the 
> > > breakage, and also confirmed that reverting it on top of -rc1 also fixes 
> > > the problem.
> > > 
> > > I've also added some additional instrumentation to my code and confirmed 
> > > that the process is blocking on poll(2) while netstat is reporting 
> > > data available on the socket.
> > > 
> > > What can I do to help track this down?
> > > 
> > 
> > Can the following patch be tested please? It is reported to fix an fio
> > regression that may be similar to what you are experiencing but has not
> > been picked up yet.
> 
> This patch appears to resolve things for me as well, at least after a 
> couple of passes.  I'll let you know if I see any further problems come up 
> with more testing.
> 

Thanks very much Sage.

-- 
Mel Gorman
SUSE Labs
