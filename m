From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of
	2005 Kernel Summit Proposed Topics)
Date: Mon, 04 Apr 2005 09:54:10 -0700
Message-ID: <1112633650.9559.142.camel@beastie>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com>
	 <1112576171.4227.5.camel@mylaptop> <20050404063456.GB30855@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20050404063456.GB30855@colo.lackof.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-04-04 at 00:34 -0600, Grant Grundler wrote:
> On Sun, Apr 03, 2005 at 05:56:11PM -0700, Dmitry Yusupov wrote:
> > I do not get your concern with memory BW. With good AMD box V40Z(SUN)
> > you can get 5.3GBytes/sec. Even with 10Gbps full speed you have 80%
> > left. PCI-X BUS BW is bigger concern...
> 
> Yes and No. PCI-X isn't fast enough but the data only crosses
> the PCI-X bus once.  Think about the data flow:
> 	1) DMA to RAM

yes.

> 	2) load into CPU cache

yes.

> 	3) store back into RAM

no. we are talking about receive side optimization only.
why do you think store back into RAM comes to the picture?
also keep in mind that we have huge L2 & L3 caches today and write
operation is usually very well buffered.

> We are down to 40% left...graphics folks won't like you.
> 
> grant
> 
