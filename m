From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Tue, 29 Mar 2005 09:19:22 -0800
Message-ID: <1112116762.5088.65.camel@beastie>
References: <424346FE.20704@cs.wisc.edu>
	 <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org>
	 <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050329152008.GD63268@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 17:20 +0200, Andi Kleen wrote:
> > In your scenario, if we're out of memory and the system needs several
> > ACK's to the swap device for pages to be released to the system, I don't
> > see how we make forward progress since without a reserved resource to
> > allocate from how does the ack make it up the stack to the storage
> > driver layer?
> 
> Typically because the RX ring of the driver has some packets left.

You can not be sure. Some NICs has very small number for possible HW
ring buffers. Under OOM pressure, most likely, host will be so slow that
resources might not just be returned back to the HW in time. Though it
depends on link-layer driver implementation.
