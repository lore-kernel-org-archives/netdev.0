From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: RCU conversion of stab
Date: Thu, 20 Jan 2011 17:39:22 +0100
Message-ID: <1295541562.2825.368.camel@edumazet-laptop>
References: <1295517052.2733.14.camel@edumazet-laptop>
	 <1295518636.2825.4.camel@edumazet-laptop>
	 <1295531299.2825.175.camel@edumazet-laptop>  <4D384E2D.5050001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61434 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab1ATQj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 11:39:27 -0500
Received: by wyb28 with SMTP id 28so805765wyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 08:39:26 -0800 (PST)
In-Reply-To: <4D384E2D.5050001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 16:01 +0100, Patrick McHardy a =C3=A9cr=
it :
> Am 20.01.2011 14:48, schrieb Eric Dumazet:
> > This patch converts stab qdisc management to RCU, so that we can pe=
rform
> > the qdisc_calculate_pkt_len() call before getting qdisc lock.
> >=20
> > This shortens the lock's held time in __dev_xmit_skb().
> >=20
> > This permits more qdiscs to get TCQ_F_CAN_BYPASS status, avoiding l=
ot of
> > cache misses and so reducing latencies.
> >=20
>=20
> Looks good to me.
>=20

Thanks for reviewing Patrick !


