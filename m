From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 09:54:37 -0700
Message-ID: <adawtazgawi.fsf@cisco.com>
References: <20060628.000715.95062023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:18768 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1750964AbWF2Qyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 12:54:41 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060628.000715.95062023.davem@davemloft.net> (David Miller's message of "Wed, 28 Jun 2006 00:07:15 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Roland, there is no way in the world we would have let
    David> support for RDMA into the kernel tree had we seen and
    David> reviewed it on netdev.  I've discussed this with Andrew
    David> Morton, and we'd like you to please revert all of the RDMA
    David> code from Linus's tree immedialtely.

    David> Folks are well aware how against RDMA and TOE type schemes
    David> the Linux networking developers are.  So the fact that none
    David> of these RDMA changes went up for review on netdev strikes
    David> me as just a little bit more than suspicious.

[I'm really on paternity leave, but this was brought to my attention
and seems important enough to respond to]

Dave, you're going to have to be more specific.  What do you mean by
RDMA?  The whole drivers/infiniband infrastructure, which handles RDMA
over IB, has been upstream for a year and a half, and was in fact
originally merged by you, so I'm guessing that's not what you mean.

If you're talking about the "RDMA CM" (drivers/infiniband/core/cma.c
et al) that was just merged, then you should be aware that that was
posted by Sean Hefty to netdev for review, multiple times (eg a quick
search finds <http://lwn.net/Articles/170202/>).  It is true that the
intention of the abstraction is to provide a common mechanism for
handling IB and iWARP (RDMA/TCP) connections, but at the moment no
iWARP code is upstream.  Right now all it does is allow IP addressing
to be used for IB connections.

In any case I think we need to find a way for Linux to support iWARP
hardware, since there are users that want this, and (some of) the
vendors are working hard to do things the right way (including cc'ing
netdev on the conversation).  I don't think it's good for Linux for
the answer to just be, "sorry, you're wrong to want to use that hardware."

 - Roland
