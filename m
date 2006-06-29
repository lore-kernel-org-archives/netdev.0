From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 12:46:28 -0700 (PDT)
Message-ID: <20060629.124628.88476747.davem@davemloft.net>
References: <20060628.000715.95062023.davem@davemloft.net>
	<adawtazgawi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34233
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932346AbWF2Tq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:46:29 -0400
To: rdreier@cisco.com
In-Reply-To: <adawtazgawi.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 29 Jun 2006 09:54:37 -0700

> In any case I think we need to find a way for Linux to support iWARP
> hardware, since there are users that want this, and (some of) the
> vendors are working hard to do things the right way (including cc'ing
> netdev on the conversation).  I don't think it's good for Linux for
> the answer to just be, "sorry, you're wrong to want to use that hardware."

We give the same response for TOE stuff.

The integration of iWARP with the Linux networking, while much better
than TOE, is still heavily flawed.

What most people might not realize when using this stuff is that:

1) None of their firewall rules will apply to the iWARP communications.
2) None of their packet scheduling configurations can be applied to
   the iWARP communications.
3) It is not possible to encapsulate iWARP traffic in IPSEC

And the list goes on and on.

This is what we don't like about technologies that implement their own
networking stack in the card firmware.
