From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 30 Mar 2005 17:24:29 +0200
Message-ID: <20050330152429.GC12672@muc.de>
References: <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave> <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain> <Pine.LNX.4.61.0503291659290.15625@chimarrao.boston.redhat.com> <1112137210.1088.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 30 Mar 2005 17:24:29 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112137210.1088.17.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> OTOH, even elcheapo pacific rim nics are beginning to show up with some
> classifiers in the hardware as well as multiple queues or rx 
> DMA rings. So you could program ACKs or all TCP packets to show up on a

Yes, but you end up with limits like "only support upto 4 iscsi connections".
which is totally impracticable. The features do not help.

The only feature that might help is an early interrupt where you
first process the packet and then later the payload (like the new
intel accelerator proposes or some chips have), but that would
probably add far too much overhead right now and does not work
on most chips anyways.

-Andi
