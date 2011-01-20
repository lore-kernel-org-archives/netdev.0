From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sfq: allow divisor to be a
 variable
Date: Thu, 20 Jan 2011 11:17:16 +0100
Message-ID: <1295518636.2825.4.camel@edumazet-laptop>
References: <1295517052.2733.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53478 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab1ATKRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 05:17:20 -0500
Received: by wwa36 with SMTP id 36so446889wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 02:17:19 -0800 (PST)
In-Reply-To: <1295517052.2733.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 10:50 +0100, Eric Dumazet a =C3=A9crit =
:
> SFQ currently uses a 1024 slots hash table, and its internal structur=
e
> (sfq_sched_data) allocation needs order-1 page on x86_64
>=20
> Allow tc command to specify a divisor value (hash table size), betwee=
n 1
> and 65536.
> If no value is provided, assume the 1024 default size.
>=20
> This allows admins to setup smaller (or bigger) SFQ for specific need=
s.
>=20
> This also brings back sfq_sched_data allocations to order-0 ones, sav=
ing
> 3KB per SFQ qdisc.
>=20
> Jesper uses ~55.000 sfq in one machine, this patch should free 165 MB=
 of
> memory.

Arg, sorry for the double post, I had a tg3 failure on my machine.

Please disregard this copy.


