From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Sun, 27 Mar 2005 23:50:53 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503272349470.30885@chimarrao.boston.redhat.com>
References: <4241D106.8050302@cs.wisc.edu> <20050324101622S.fujita.tomonori@lab.ntt.co.jp>
 <1111628393.1548.307.camel@beastie> <20050324113312W.fujita.tomonori@lab.ntt.co.jp>
 <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random>
 <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
 <20050326224621.61f6d917.davem@davemloft.net>
 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
 <20050327203458.02bd73ee.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dmitry_yus@yahoo.com, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050327203458.02bd73ee.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Mar 2005, David S. Miller wrote:
> On Sun, 27 Mar 2005 22:54:11 -0500 (EST)
> Rik van Riel <riel@redhat.com> wrote:
> 
> >    (SO_MEMALLOC?)
> 
> Interesting top-down scheme.
> 
> We could also make a way to adjust the GFP_ATOMIC reserve
> thresholds too.  That seems a bit more generic.

That might work, as long as we can guarantee that each
SO_MEMALLOC socket has at least N amount of memory available
just for itself, so none of these sockets get to deadlock.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
