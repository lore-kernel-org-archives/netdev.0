From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Mon, 4 Apr 2005 10:31:25 -0600
Message-ID: <20050404163125.GA6809@colo.lackof.org>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com> <1112576171.4227.5.camel@mylaptop> <20050404063456.GB30855@colo.lackof.org> <20050404001000.5fa8f206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dmitry_yus@yahoo.com, open-iscsi@googlegroups.com, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050404001000.5fa8f206.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 12:10:00AM -0700, David S. Miller wrote:
> On Mon, 4 Apr 2005 00:34:56 -0600
> Grant Grundler <grundler@parisc-linux.org> wrote:
> 
> > Yes and No. PCI-X isn't fast enough but the data only crosses
> > the PCI-X bus once.  Think about the data flow:
> > 	1) DMA to RAM
> > 	2) load into CPU cache
> > 	3) store back into RAM
> > 
> > We are down to 40% left...graphics folks won't like you.
> 
> But you're missing the point, which is that the memory system
> always catches up to the networking technology.

No. Bus bandwidth catches up to "a" networking technology - not
the "current" technology.
Networking and graphics are usually starving for bus bandwidth.

> We'll have that %60 back before you know it when we have
> PCI-Z and DDR8 or whatever even in $500.00USD desktop machines.

Yes, I agree. That's certainly how it went for 100bt and gige.
Even laptops come with gige now. But we aren't in that part
"of the curve" for IB or 10GigE *yet*.

> And those systems will be present by the time we put together
> this complicated infrastructure for RDMA.

And that will be fine for "general use".

> RDMA is like cache coloring page allocators, it's for yesterday's
> technology that we won't be using tomorrow. :-)
> 
> Those steps #2 and #3 in your data flow are powerful, it is what
> gives us flexibility.

Agreed - some very cool things have been done with it.
And for general use, it'll perf sufficiently well over gige.
In the future, I agree IB or 10gigE will too.

> And in a general purpose OS that is important.

I think most of the people interested in IB and 10GigE aren't looking
for "general use". They have a particular application in mind
and they want to maximize performance for dollar spent.
Things like "science appliance", "router", "data warehouse" come to mind.

"General Use" will be a reality only when the dollar cost comes down
so those new technologies can compete with gige.

thanks,
grant
