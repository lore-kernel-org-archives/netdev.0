From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
 2005 Kernel Summit Proposed Topics)
Date: Mon, 4 Apr 2005 00:10:00 -0700
Message-ID: <20050404001000.5fa8f206.davem@davemloft.net>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com>
	<1112576171.4227.5.camel@mylaptop>
	<20050404063456.GB30855@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmitry_yus@yahoo.com, open-iscsi@googlegroups.com, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20050404063456.GB30855@colo.lackof.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2005 00:34:56 -0600
Grant Grundler <grundler@parisc-linux.org> wrote:

> Yes and No. PCI-X isn't fast enough but the data only crosses
> the PCI-X bus once.  Think about the data flow:
> 	1) DMA to RAM
> 	2) load into CPU cache
> 	3) store back into RAM
> 
> We are down to 40% left...graphics folks won't like you.

But you're missing the point, which is that the memory system
always catches up to the networking technology.

We'll have that %60 back before you know it when we have
PCI-Z and DDR8 or whatever even in $500.00USD desktop machines.

And those systems will be present by the time we put together
this complicated infrastructure for RDMA.

RDMA is like cache coloring page allocators, it's for yesterday's
technology that we won't be using tomorrow. :-)

Those steps #2 and #3 in your data flow are powerful, it is what
gives us flexibility.  And in a general purpose OS that is important.
