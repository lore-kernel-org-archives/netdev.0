From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Mon, 04 Apr 2005 11:57:52 -0700
Message-ID: <42518E30.2090207@hp.com>
References: <20050324215922.GT14202@opteron.random>	<424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>	<20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>	<20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>	<20050326224621.61f6d917.davem@davemloft.net>	<52vf7bwo4w.fsf@topspin.com>	<1112042936.5088.22.camel@beastie> <20050328223203.GC28983@kvack.org> <1112465317.24936.10.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1112465317.24936.10.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> What RDMA gives us is zero-copy on receive and new networking api which
> has a potential to be HW accelerated. SoftRDMA will never avoid copying
> on receive. But benefit for SoftRDMA would be its availability on client
> sides. It is free and it could be easily deployed. Soon Intel & Co will
> give us 2,4,8... multi-core CPUs for around 200$ :), So, who cares if
> one of those cores will do receive side copying?

20 years ago, in certain circles at least, people were saying "With 32-bits of 
addressing, who cares if we allocate much memory" :)

Speaking a bit more prosaicly, if that core is sitting there churning through 
data copies, what affect does that have on the rest of the bus(ses) and the 
memory?  What else will the client want to be able to push around that those 
data copies may preclude?

rick jones
