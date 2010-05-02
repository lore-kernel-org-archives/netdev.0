From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sun, 2 May 2010 23:54:50 +0200
Message-ID: <20100502215450.GC2673@gargoyle.fritz.box>
References: <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop> <20100502154649.GA18063@gargoyle.fritz.box> <1272818131.2173.127.camel@edumazet-laptop> <20100502212550.GA2673@gargoyle.fritz.box> <1272836755.2173.153.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54627 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab0EBVwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 17:52:19 -0400
Content-Disposition: inline
In-Reply-To: <1272836755.2173.153.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 02, 2010 at 11:45:55PM +0200, Eric Dumazet wrote:
> Le dimanche 02 mai 2010 =E0 23:25 +0200, Andi Kleen a =E9crit :
>=20
> > It's pointless to send an IPI to your thread sibling for this.=20
> > Everything it could do you can do yourself too with the same perfor=
mance.
> >=20
> > -Andi
>=20
> Amen

That is in terms of cache locality.

>=20
> Tests just prove the reverse.

What do you mean?=20

>=20
> I have some collegues that disable HyperThreading for exact same
> reasons. I wonder why Intel designed HT. Should be marketing I guess.

HT (especially Nehalem HT) is useful for a wide range of workloads.
Just handling network interrupts for its thread sibling is not one of t=
hem.

-Andi

