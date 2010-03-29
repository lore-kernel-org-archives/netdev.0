From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Mon, 29 Mar 2010 14:01:04 -0700
Message-ID: <4BB11510.9000302@hp.com>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org>	<4BB0DCF6.9020401@hp.com>	<20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	netdev@vger.kernel.org
To: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:34399 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab0C2VBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 17:01:08 -0400
In-Reply-To: <20100329205035.GA32656@laped.iglesias.mooo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Are things really that bad?
> 
> These "transactional" IPv6 apps all have the option to stick to 1280
> sized datagrams to avoid the problem. If throughput is an issue these
> apps will surely benefit from proper PMTUD anyway or?

I would get the alphabet soup completely garbled, but the DNS folks are talking 
about EDNS (?) message sizes upwards of 4096 bytes - encryption/authentication 
and other angels being asked to dance on the head of the DNS pin are asking for 
more and more space in the messages.

So, someone will have to blink somewhere - either DNS will have to go TCP and 
*possibly* take RTT hits there depending on various patch streams, or the IEEE 
will have to sanction jumbo frames and people deploy them widely, or it will 
have to become feasible to actually do the occasional IPv6 datagram 
fragmentation and get a timely retransmission out of a UDP application on a PMTU 
hit.

rick jones
