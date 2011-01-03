From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] ifb: add performance flags
Date: Mon, 03 Jan 2011 12:40:55 -0800 (PST)
Message-ID: <20110103.124055.68142309.davem@davemloft.net>
References: <20110103193703.GA1977@del.dom.local>
	<20110103.114033.28807428.davem@davemloft.net>
	<1294086922.2711.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47584
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752930Ab1ACUkY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 15:40:24 -0500
In-Reply-To: <1294086922.2711.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Jan 2011 21:35:22 +0100

> Le lundi 03 janvier 2011 =E0 11:40 -0800, David Miller a =E9crit :
>> I think at least TSO6 would very much be appropriate here.
>=20
> Yes, why not, I am only wondering why loopback / dummy (and others ?)
> only set NETIF_F_TSO :)

TSO6 probably didn't exist when the current set were added,
at least in the loopback case that's almost certainly the
reason.

> Since I want to play with ECN, I might also add NETIF_F_TSO_ECN ;)
>=20
> For other flags, I really doubt it can matter on ifb ?
>=20
> [PATCH v3 net-next-2.6] ifb: add performance flags
>=20
> IFB can use the full set of features flags (NETIF_F_SG |
> NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) t=
o
> avoid unnecessary split of some packets (GRO for example)
>=20
> Changli suggested to also set vlan_features, NETIF_F_TSO6,
> NETIF_F_TSO_ECN.
>=20
> Jarek suggested to add NETIF_F_HW_VLAN_TX as well.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, thanks Eric.
