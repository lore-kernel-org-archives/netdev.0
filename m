From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Tue, 08 Nov 2011 14:00:00 -0500 (EST)
Message-ID: <20111108.140000.543570939575214751.davem@davemloft.net>
References: <1320191893.4728.13.camel@edumazet-laptop>
	<20111104.222851.1376278499619626232.davem@davemloft.net>
	<1320478829.16609.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: spiked.yar@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1KHTAG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:00:06 -0500
In-Reply-To: <1320478829.16609.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Nov 2011 08:40:29 +0100

> Le vendredi 04 novembre 2011 =E0 22:28 -0400, David Miller a =E9crit =
:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 02 Nov 2011 00:58:13 +0100
>>=20
>> > Please try following patch, thanks !
>> >=20
>> > [PATCH] l2tp: handle fragmented skbs in receive path
>> >=20
>> > Modern drivers provide skb with fragments, and L2TP doesnt properl=
y
>> > handles them.
>> >=20
>> > Some bad frames can also trigger panics because of insufficent che=
cks.
>> >=20
>> > Reported-by: Misha Labjuk <spiked.yar@gmail.com>
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> I'm still waiting for testing results of this patch.
>=20
> Of course.
>=20
> If you prefer, I can submit a smaller patch for the obvious bug first=
,
> and I can respin the thing when net-next reopens.
>=20
> [PATCH] l2tp: fix l2tp_udp_recv_core()
>=20
> pskb_may_pull() can change skb->data, so we have to load ptr/optr at =
the
> right place.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yes, this is easier to digest right now.

Applied.
