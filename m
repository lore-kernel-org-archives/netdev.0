From: Glen Turner <gdt@gdt.id.au>
Subject: Re: UDP path MTU discovery
Date: Thu, 01 Apr 2010 10:27:44 +1030
Message-ID: <1270079864.2389.48.camel@ilion>
References: <1269561751.2891.8.camel@ilion>
	 <20100325.202424.201654947.davem@davemloft.net>
	 <87bpe825z2.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:48546 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755072Ab0CaX40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 19:56:26 -0400
In-Reply-To: <87bpe825z2.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-03-28 at 10:41 +0200, Andi Kleen wrote:

> It means though that all IPv6 UDP applications essentially have
> to implement path mtu discovery support (which is non trivial) 

It is trivial from the applications point of view to let the
kernel find the UDP Path MTU. We just need more information
from the kernel as to when it would like to see those packets
(ie, for performance we'd like to feed in the packet to re-send
as soon as the ICMP Packet Too Big arrives for the previous
packet).

> Will be likely a long time until they're all fixed.

There's no need to make that assumption.  We'd very much like
transactional UDP protocols to work well in advanced networks.
The other choices -- holding down millions of TCP sockets,
or using new protocols (and there are competing proposals) --
don't exactly fill our operations teams with confidence.

We'd very much like to use UDP were we can and something else
where we must.

> Seems like a big hole not considered by the IPv6 designers?

Yeah. The sockets API for IPv6 required an additional feature that
the IETF did not foresee.

-- 
 Glen Turner
 www.gdt.id.au/~gdt

