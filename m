From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Mon, 29 Mar 2010 10:01:42 -0700
Message-ID: <4BB0DCF6.9020401@hp.com>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Glen Turner <gdt@gdt.id.au>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:6837 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab0C2RBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 13:01:47 -0400
In-Reply-To: <877how25kx.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In theory one could probably add some hack in the the kernel UDP code
> to hold one packet and retransmit it immediately with fragments when
> the ICMP comes in. However that would be quite far in behaviour from
> traditional UDP and be considered very ugly. It could also mess up
> congestion avoidance schemes done by the application. 
> 
> Still might be preferable over rewriting zillions of applications?

But which of the last N datagrams sent by the application should be retained for 
retransmission?  It could be scores if not hundreds of datagrams depending on 
the behaviour of the application and the latency to the narrow part of the network.

That the IPv6 specification was heavily "influenced" by "the router guys" seems 
increasingly clear...

rick jones
