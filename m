From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Wed, 30 Mar 2005 11:00:06 -0500
Message-ID: <20050330160006.GE2927@kvack.org>
References: <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <52vf7bwo4w.fsf@topspin.com> <1112042936.5088.22.camel@beastie> <20050328223203.GC28983@kvack.org> <52psxjt9yw.fsf_-_@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
Content-Disposition: inline
In-Reply-To: <52psxjt9yw.fsf_-_@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 07:19:35PM -0800, Roland Dreier wrote:
>     Benjamin> Agreed.  After working on a full TOE implementation, I
>     Benjamin> think that the niche market most TOE vendors are
>     Benjamin> pursuing is not one that the Linux community will ever
>     Benjamin> develop for.  Hardware vendors that gradually add
>     Benjamin> offloading features from the NIC realm to speed up the
>     Benjamin> existing network stack are a much better fit with Linux.
> 
> I have to admit I don't know much about the TOE / RDMA/TCP / RNIC (or
> whatever you want to call it) world.  However I know that the large
> majority of InfiniBand use right now is running on Linux, and I hope
> the Linux community is willing to work with the IB community.

My comments were more directed to Full TOE implementations, which tend 
to suffer from incomplete feature coverage if compared to the native 
Linux TCP/IP stack.  Wedging a complete network stack onto a piece of 
hardware does allow for better performance characteristics on workloads 
where the networking overhead matters, but it comes at the cost of not 
being able to trivially change the resulting stack.  Plus there are 
very few vendors who are willing to release firmware code to the open 
source community.

> InfiniBand adoption is strong right now, with lots of large clusters
> being built.  It seems reasonable that RDMA/TCP should be able to
> compete in the same market.  Whether InfiniBand or RDMA/TCP or both
> will survive or prosper is a good question, and I think it's too early
> to tell yet.

I'm curious how the 10Gig ethernet market will pan out.  Time and again 
the market has shown that ethernet always has the cost advantage in the 
end.  If something like Intel's I/O Acceleration Technology makes it 
that much easier for commodity ethernet to achieve similar performance 
characteristics over ethernet to that of IB and fibre channel, the cost 
advantage alone might switch some new customers over.  But the hardware 
isn't near what IB offers today, making IB an important niche filler.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
