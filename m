From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 10:59:21 +0400
Message-ID: <20060725065921.GB30561@2ka.mipt.ru>
References: <adasllh9kj0.fsf@cisco.com> <20060724.150613.54186472.davem@davemloft.net> <20060725055127.GA5103@2ka.mipt.ru> <20060724.234853.112197982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: rdreier@cisco.com, ak@suse.de, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56503 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751480AbWGYHDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 03:03:33 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060724.234853.112197982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 24, 2006 at 11:48:53PM -0700, David Miller (davem@davemloft.net) wrote:
> > And if that CPU is very busy?
> > Linux should somehow tell NIC that some CPUs are valid and some are not
> > right now, but not in a second, so scheduler must be tightly bound with
> > network internals.
> 
> Yes, it is research problem.
> 
> Most of the time, even stateless version will improve things.
> From another viewpoint, even in worst case, it can be no
> worse than current situation. :)
> 
> BTW, such dynamic remapping is provided for in the NDIS interfaces.
> There is an indexing table that is gone through using computed hash to
> get "cpu number".

I think we should force Linux scheduler to export some easily accessed CPU
statistic, so that info might be used by irq layer/protocol processing.

As a side completely unrelated to either my or others work note :) - 
I think it is a nanooptimisation - we get a bit of performance here, 
and lose those bit in other place.
When bag is filled, there is no much sence of rearranging some stuff
inside to be able to place another one - it is better to buy new bag.

-- 
	Evgeniy Polyakov
