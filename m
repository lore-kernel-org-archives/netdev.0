From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Fri, 30 Jun 2006 13:51:19 -0700
Message-ID: <ada3bdmfjug.fsf@cisco.com>
References: <20060628.000715.95062023.davem@davemloft.net>
	<adawtazgawi.fsf@cisco.com>
	<20060629.124628.88476747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:44809 "EHLO
	sj-iport-3.cisco.com") by vger.kernel.org with ESMTP
	id S932231AbWF3UvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 16:51:24 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.124628.88476747.davem@davemloft.net> (David Miller's message of "Thu, 29 Jun 2006 12:46:28 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You snipped my question about what specifically you wanted reverted,
so I'm going to assume that after cooling down and understanding the
situation, you're OK with everything that's in Linus's tree...

 > The integration of iWARP with the Linux networking, while much better
 > than TOE, is still heavily flawed.
 > 
 > What most people might not realize when using this stuff is that:
 > 
 > 1) None of their firewall rules will apply to the iWARP communications.
 > 2) None of their packet scheduling configurations can be applied to
 >    the iWARP communications.
 > 3) It is not possible to encapsulate iWARP traffic in IPSEC

Yes, there are tradeoffs with iWARP.  However, there seem to be users
who are willing to make those tradeoffs.  And I can't think of a
single other example of a case where we refused to merge a driver, not
because of any issues with the driver code, but because we don't like
the hardware it drives and think that people shouldn't be able to use
the HW with Linux.  And it makes me sad that we're doing that here.

Don't get me wrong, I'm all for rejecting patches that make the core
networking stack worse or harder to maintain or are bad patches for
whatever reason.  I know that the present is science fiction, but I
always thought that the forbidden technologies would be stuff like
nanotech or human cloning -- I never would have guessed that iWARP
would be in that category.

Anyway, what is your feeling about changes strictly under
drivers/infiniband that add low-level driver support for iWARP
devices?  The changes that Steve Wise proposed aren't strictly
necessary for iWARP support -- they just make things work better when
routes change.

Thanks,
  Roland
