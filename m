From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 15:11:06 -0500
Message-ID: <1151611866.11739.57.camel@trinity.ogc.int>
References: <20060628.000715.95062023.davem@davemloft.net>
	 <adawtazgawi.fsf@cisco.com>  <20060629.124628.88476747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:5136 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932395AbWF2ULG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:11:06 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.124628.88476747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-29 at 12:46 -0700, David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Thu, 29 Jun 2006 09:54:37 -0700
> 
> > In any case I think we need to find a way for Linux to support iWARP
> > hardware, since there are users that want this, and (some of) the
> > vendors are working hard to do things the right way (including cc'ing
> > netdev on the conversation).  I don't think it's good for Linux for
> > the answer to just be, "sorry, you're wrong to want to use that hardware."
> 
> We give the same response for TOE stuff.

What does the word "we" represent in this context? Is it the Linux
community at large, Linux and Andrew, you? I'm not trying to be
argumentative, I just want to understand how carefully and by whom iWARP
technology has been considered.

> 
> The integration of iWARP with the Linux networking, while much better
> than TOE, is still heavily flawed.
> 
> What most people might not realize when using this stuff is that:

Agreed, the patch improves some things, but doesn't address others. But
isn't this position a condemnation of the good to spite the bad? 

> 
> 1) None of their firewall rules will apply to the iWARP communications.
> 2) None of their packet scheduling configurations can be applied to
>    the iWARP communications.
> 3) It is not possible to encapsulate iWARP traffic in IPSEC
> 
> And the list goes on and on.

It does, however, this position statement makes things worse, not
better. By this I mean that deep adapters (iSCSI, iWARP) are even more
debilitated by not being able to snoop MTU changes, etc... and are
therefore forced to duplicate sub-systems (e.g. ARP, ICMP, ...) already
ably implemented in host software.

> This is what we don't like about technologies that implement their own
> networking stack in the card firmware.

Doesn't this position force vendors to build deeper adapters, not
shallower adapters? Isn't this exactly the opposite of what is intended?

> 

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

