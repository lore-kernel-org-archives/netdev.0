From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Thu, 29 Jun 2006 15:47:13 -0500
Message-ID: <1151614033.11739.82.camel@trinity.ogc.int>
References: <adawtazgawi.fsf@cisco.com>
	 <20060629.124628.88476747.davem@davemloft.net>
	 <1151611866.11739.57.camel@trinity.ogc.int>
	 <20060629.131938.55726619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:313 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932505AbWF2UrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:47:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.131938.55726619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-29 at 13:19 -0700, David Miller wrote:
> From: Tom Tucker <tom@opengridcomputing.com>
> Date: Thu, 29 Jun 2006 15:11:06 -0500
> 
> > Doesn't this position force vendors to build deeper adapters, not
> > shallower adapters? Isn't this exactly the opposite of what is intended?
> 
> Nope.
> 
> Look at what the networking developers give a lot of attention and
> effort to, things like TCP Large Receive Offload, and Van Jacobson net
> channels, both of which are fully stack integrated receive performance
> enhancements.  They do not bypass netfilter, they do not bypass
> packet scheduling, and yet they provide a hardware assist performance
> improvement for receive.

These technologies are integrated because someone chose to and was
allowed to integrate them. I contend that iWARP could be equally well
integrated if the decision was made to do so. It would, however, require
cooperation from both the hardware vendors and the netdev maintainers.

> 
> This has been stated over and over again.

For TOE, you are correct, however, for iWARP, you can't do RDMA (direct
placement into application buffers) without state in the adapter. I
personally tried very hard to build an adapter without doing so, but
alas, I failed ;-) 

> 
> If companies keep designing undesirable hardware that unnecessarily
> takes features away from the user, that really is not our problem.

I concede that features have been lost, but some applications benefit
greatly from RDMA. For these applications and these customers, the
hardware is not undesirable and the fact that netfilter won't work on
their sub 5us latency adapter is not perceived to be a big issue. The
mention of packet scheduling would cause an apoplectic seizure...unless
it were in the hardware...

All that verbiage aside, I believe that it is not a matter of whether it
is possible to integrate iWARP it is question of whether it is
permissible.




