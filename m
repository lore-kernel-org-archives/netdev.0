From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Thu, 31 Mar 2005 14:05:13 -0800
Message-ID: <1112306713.4613.15.camel@beastie>
References: <20050329152008.GD63268@muc.de>
	 <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>
	 <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random>
	 <20050330153948.GE12672@muc.de> <20050330154418.GE32111@g5.random>
	 <20050330160255.GG12672@muc.de> <20050330161522.GH32111@g5.random>
	 <20050331115012.GP24804@muc.de>  <20050331170923.GA6546@g5.random>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, jamal <hadi@cyberus.ca>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi@googlegroups.com
In-Reply-To: <20050331170923.GA6546@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 19:09 +0200, Andrea Arcangeli wrote:
> > Even with all that work it is  not the 100% solution some people on this thread
> > seem to be lusting for. 
> 
> I thought it was more than enough, all they care about is not to
> deadlock anymore, I don't think anybody cares about the performance of
> the deadlock-scenario.

True. this is all we need to make "soft" iSCSI viable alternative to FC.
Btw, other OSes can do that today.

> I agree with Jamal that his suggestion to use an high-per ring is
> very good (I didn't even know some card supported this feature), so if
> somebody wants the deadlock scenario not to run in "degraded mode", they
> will have to use some more advanced hardware the way Jamal is suggesting
> (or get rid of TCP all together and use TCP/IP offload with the security
> risks it introduces or RDMA or whatever other point to point high perf
> DMA technology like quadrix etc..).

One good example is Neterion 10Gbps card. It supports up to 8 priority
rings. Could someone point me to the API which driver could utilize to
configure ring's priorities with 2.6.x? Thanks.
