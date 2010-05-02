From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 23:45:55 +0200
Message-ID: <1272836755.2173.153.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502154649.GA18063@gargoyle.fritz.box>
	 <1272818131.2173.127.camel@edumazet-laptop>
	 <20100502212550.GA2673@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41816 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095Ab0EBVqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 17:46:01 -0400
Received: by bwz19 with SMTP id 19so1004173bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 14:46:00 -0700 (PDT)
In-Reply-To: <20100502212550.GA2673@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 23:25 +0200, Andi Kleen a =C3=A9crit :

> It's pointless to send an IPI to your thread sibling for this.=20
> Everything it could do you can do yourself too with the same performa=
nce.
>=20
> -Andi

Amen

Tests just prove the reverse.

I have some collegues that disable HyperThreading for exact same
reasons. I wonder why Intel designed HT. Should be marketing I guess.



