From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Sun, 28 Mar 2010 10:41:37 +0200
Message-ID: <87bpe825z2.fsf@basil.nowhere.org>
References: <1269561751.2891.8.camel@ilion>
	<20100325.202424.201654947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gdt@gdt.id.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48829 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab0C1Ilo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 04:41:44 -0400
In-Reply-To: <20100325.202424.201654947.davem@davemloft.net> (David Miller's message of "Thu, 25 Mar 2010 20:24:24 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Glen Turner <gdt@gdt.id.au>
> Date: Fri, 26 Mar 2010 10:32:31 +1030
>
>> This differs from TCP, where it is the kernel -- and not
>> the application -- which organises retransmission. On
>> receiving a ICMP Fragmentation Needed the kernel can
>> immediately re-probe the path MTU wiht no waiting for
>> an exponential timer to expire.
>
> So the argument is, the kernel TCP does retransmission smart,
> userspace UDP apps do it stupidly, so let's turn off the feature
> instead of fixing userspace.
>
> Right?
>
> Sorry, fix this correctly in the user apps.  Putting the
> blame on UDP path MTU discovery is placing it in the
> wrong spot.

It means though that all IPv6 UDP applications essentially have
to implement path mtu discovery support (which is non trivial) 

Will be likely a long time until they're all fixed.

Seems like a big hole not considered by the IPv6 designers?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
