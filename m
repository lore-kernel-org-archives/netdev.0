From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 12:59:49 -0700 (PDT)
Message-ID: <20080920.125949.193703969.davem@davemloft.net>
References: <1221926529.1343.140.camel@localhost.localdomain>
	<20080920091918.0ffaef8c@infradead.org>
	<1221932404.1343.196.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: dwalker@mvista.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753206AbYITUAW@vger.kernel.org>
In-Reply-To: <1221932404.1343.196.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Walker <dwalker@mvista.com>
Date: Sat, 20 Sep 2008 10:40:04 -0700

> Dave didn't supply the users of his code, or what kind of improvement
> was seen, or the case in which it would be needed. I think Dave knowns
> his subsystem, but the code on the surface looks like an end run around
> some other problem area..

I posted an example use case on netdev a few days ago, and
the block layer example is in Jen's block layer tree.

It's for networking cards that don't do flow seperation on
receive using multiple RX queues and MSI-X interrupts.  It's
also for things like IPSEC where the per-packet cpu usage
is so huge (to do the crypto) that it makes sense to even
split up the work to multiple cpus within the same flow.
