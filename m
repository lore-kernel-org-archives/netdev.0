From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ifb: add performance flags to
 dev->features
Date: Tue, 28 Dec 2010 13:50:13 -0800 (PST)
Message-ID: <20101228.135013.39173075.davem@davemloft.net>
References: <20101220130247.GB9325@ff.dom.local>
	<AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
	<1292855120.2800.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, jarkao2@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445Ab0L1Vtn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 16:49:43 -0500
In-Reply-To: <1292855120.2800.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Dec 2010 15:25:20 +0100

> Le lundi 20 d=E9cembre 2010 =E0 22:05 +0800, Changli Gao a =E9crit :
>> 2010/12/20 Jarek Poplawski <jarkao2@gmail.com>:
>> >
>> > IMHO it should, (probably even more, like loopback) but we should
>> > consider mirred can xmit to other than ifb too.
>> >
>>=20
>> I also think so. And when making ifb a multiqueue NIC, I tried to ad=
d
>> these dev features to ifb. :)
>>=20
>=20
> This has litle to do with your multiqueue work,
> its more an effect of GRO being more and more deployed.
>=20
> I dont see dev->features being changed in one of your previous patche=
s.
> I did dummy case in commit 6d81f41c58c6
>=20
> [PATCH net-next-2.6] ifb: add performance flags to dev->features
>=20
> IFB can use the full set of features flags (NETIF_F_SG |
> NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) t=
o
> avoid unecessary split of some packets (GRO for example)
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Changli has suggested that these flags can also be set in
->vlan_features, please address that if you expect me to
apply the change.
