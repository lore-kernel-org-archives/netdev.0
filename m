From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 17:44:18 +0200
Message-ID: <20050330154418.GE32111@g5.random>
References: <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random> <20050330153948.GE12672@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050330153948.GE12672@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 05:39:48PM +0200, Andi Kleen wrote:
> An unsolveable one IMHO. You can just try to be good enough. For that

I think it's solvable with an algorithm I outlined several emails ago.

> Basically same thing we do about highmem vs lowmem.

That's not a deadlock, the lowmem vs highmem issue is about running out
of memory too early and getting a -ENOMEM out of a syscall (or a
oom-killing).

A few buggy kernels deadlocked in such condition but that just because
those buggy kernels would deadlock in most oom condition anyway, current
2.6 kernels and latest 2.4 shouldn't deadlock on a lowmem shortage.
