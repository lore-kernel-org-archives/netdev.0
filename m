From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 30 Mar 2005 17:39:48 +0200
Message-ID: <20050330153948.GE12672@muc.de>
References: <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 30 Mar 2005 17:39:48 +0200
To: Andrea Arcangeli <andrea@suse.de>
Content-Disposition: inline
In-Reply-To: <20050330153313.GD32111@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> You can be right the receive path may be less of a pratical issue, but
> it's still very much an at least theoretical source of deadlock.

An unsolveable one IMHO. You can just try to be good enough. For that
probably simple statistical solutions (like RED on ingres queues and
very aggressive freeing of secondary caches like dcache etc.)
will be hopefully sufficient.

Basically same thing we do about highmem vs lowmem.

-Andi
