From: Ming Zhang <mingz@ele.uri.edu>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
	2005 Kernel Summit Proposed Topics)
Date: Mon, 04 Apr 2005 08:56:56 -0400
Message-ID: <1112619415.2880.5.camel@localhost.localdomain>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com>
	 <1112576171.4227.5.camel@mylaptop> <20050404063456.GB30855@colo.lackof.org>
Reply-To: mingz@ele.uri.edu
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi <open-iscsi@googlegroups.com>
In-Reply-To: <20050404063456.GB30855@colo.lackof.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

yes, it travel 3 times instead of 1 time. and it is duplex. send traffic
will take another 20%. so total 80% or it can never run that fast.

ming

On Mon, 2005-04-04 at 02:34, Grant Grundler wrote:
> On Sun, Apr 03, 2005 at 05:56:11PM -0700, Dmitry Yusupov wrote:
> > I do not get your concern with memory BW. With good AMD box V40Z(SUN)
> > you can get 5.3GBytes/sec. Even with 10Gbps full speed you have 80%
> > left. PCI-X BUS BW is bigger concern...
> 
> Yes and No. PCI-X isn't fast enough but the data only crosses
> the PCI-X bus once.  Think about the data flow:
> 	1) DMA to RAM
> 	2) load into CPU cache
> 	3) store back into RAM
> 
> We are down to 40% left...graphics folks won't like you.
> 
> grant
