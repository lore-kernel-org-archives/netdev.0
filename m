From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Tue, 29 Mar 2005 17:00:35 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com>
References: <424346FE.20704@cs.wisc.edu>  <20050324233921.GZ14202@opteron.random>
 <20050325034341.GV32638@waste.org>  <20050327035149.GD4053@g5.random>
 <20050327054831.GA15453@waste.org>  <1111905181.4753.15.camel@mylaptop>
 <20050326224621.61f6d917.davem@davemloft.net>
 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
 <20050329152008.GD63268@muc.de>  <1112116762.5088.65.camel@beastie>
 <1112130512.1077.107.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, Andi Kleen <ak@muc.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1112130512.1077.107.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Mar 2005, jamal wrote:

> If yes, the solution maybe to just drop all non-high-prio packets coming
> in during the denial of service attack (for lack of better term). In
> other words some strict prioritization scheduling (or rate control) at
> the network level either in the NIC or ingress qdisc level.

Exactly, that is the proposal.  However, we often will need
to get the packets off the network card before we can decide
whether or not they're high priority.

Also, there can be multiple high priority sockets, and we
need to ensure they all make progress.  Hence the mempool
idea.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
