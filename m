From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Sun, 27 Mar 2005 10:31:15 -0800
Message-ID: <20050327103115.5c746472.davem@davemloft.net>
References: <4241D106.8050302@cs.wisc.edu>
	<20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	<1111628393.1548.307.camel@beastie>
	<20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	<1111633846.1548.318.camel@beastie>
	<20050324215922.GT14202@opteron.random>
	<424346FE.20704@cs.wisc.edu>
	<20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org>
	<20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org>
	<1111905181.4753.15.camel@mylaptop>
	<20050326224621.61f6d917.davem@davemloft.net>
	<1111907130.4753.32.camel@mylaptop>
	<20050326235712.25f9ca36.davem@davemloft.net>
	<1111911493.5824.12.camel@mylaptop>
	<4246FAD5.5080700@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, mpm@selenic.com, andrea@suse.de,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: Mike Christie <michaelc@cs.wisc.edu>
In-Reply-To: <4246FAD5.5080700@cs.wisc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Mar 2005 10:26:29 -0800
Mike Christie <michaelc@cs.wisc.edu> wrote:

> reliable receive is ciritical for WRITEs. Even if the WRITE is executed
> successfully on the remote device, if we cannot receive the return status
> from the device the operation will fail at the iscsi driver side due to a
> SCSI timeout.

I keep hearing this word "reliable", it means something very
different for TCP over a transport like IP than it does
for the SCSI layer.

It is, in fact, the whole difficulty of implementing iSCSI:
being able to cope with this difference in expectations.

All I can see is that the SCSI layer's timeout is inappropriate
for something like iSCSI, not that TCP or networking needs
to change in some way.
