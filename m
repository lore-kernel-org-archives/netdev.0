From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Mon, 4 Apr 2005 00:34:56 -0600
Message-ID: <20050404063456.GB30855@colo.lackof.org>
References: <67D69596DDF0C2448DB0F0547D0F947E01781F2E@yogi.asicdesigners.com> <1112576171.4227.5.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112576171.4227.5.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 05:56:11PM -0700, Dmitry Yusupov wrote:
> I do not get your concern with memory BW. With good AMD box V40Z(SUN)
> you can get 5.3GBytes/sec. Even with 10Gbps full speed you have 80%
> left. PCI-X BUS BW is bigger concern...

Yes and No. PCI-X isn't fast enough but the data only crosses
the PCI-X bus once.  Think about the data flow:
	1) DMA to RAM
	2) load into CPU cache
	3) store back into RAM

We are down to 40% left...graphics folks won't like you.

grant
