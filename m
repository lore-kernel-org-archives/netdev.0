From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
 from the host TCP port space.
Date: Wed, 15 Aug 2007 22:26:55 -0400
Message-ID: <46C3B5EF.5060409@garzik.org>
References: <46B883B5.8040702@opengridcomputing.com>	<46BB61D0.4090101@opengridcomputing.com>	<46BB89C0.4040303@ichips.intel.com> <20070809.145534.102938208.davem@davemloft.net> <46C310E1.7020503@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mshefty@ichips.intel.com,
	rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48673 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765691AbXHPC1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:27:05 -0400
In-Reply-To: <46C310E1.7020503@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> 
> 
> David Miller wrote:
>> From: Sean Hefty <mshefty@ichips.intel.com>
>> Date: Thu, 09 Aug 2007 14:40:16 -0700
>>
>>> Steve Wise wrote:
>>>> Any more comments?
>>> Does anyone have ideas on how to reserve the port space without using 
>>> a struct socket?
>>
>> How about we just remove the RDMA stack altogether?  I am not at all
>> kidding.  If you guys can't stay in your sand box and need to cause
>> problems for the normal network stack, it's unacceptable.  We were
>> told all along the if RDMA went into the tree none of this kind of
>> stuff would be an issue.
> 
> I think removing the RDMA stack is the wrong thing to do, and you 
> shouldn't just threaten to yank entire subsystems because you don't like 
> the technology.  Lets keep this constructive, can we?  RDMA should get 
> the respect of any other technology in Linux.  Maybe its a niche in your 
> opinion, but come on, there's more RDMA users than say, the sparc64 
> port.  Eh?

It's not about being a niche.  It's about creating a maintainable 
software net stack that has predictable behavior.

Needing to reach out of the RDMA sandbox and reserve net stack resources 
away from itself travels a path we've consistently avoided.


>> I will NACK any patch that opens up sockets to eat up ports or
>> anything stupid like that.
> 
> Got it.

Ditto for me as well.

	Jeff


