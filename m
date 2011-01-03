From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] ifb: add performance flags
Date: Mon, 03 Jan 2011 11:40:33 -0800 (PST)
Message-ID: <20110103.114033.28807428.davem@davemloft.net>
References: <20101228230709.GA2088@del.dom.local>
	<1293999876.2535.211.camel@edumazet-laptop>
	<20110103193703.GA1977@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, xiaosuo@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751285Ab1ACTkC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 14:40:02 -0500
In-Reply-To: <20110103193703.GA1977@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 3 Jan 2011 20:37:03 +0100

> On Sun, Jan 02, 2011 at 09:24:36PM +0100, Eric Dumazet wrote:
>> Le mercredi 29 d=E9cembre 2010 ?? 00:07 +0100, Jarek Poplawski a =E9=
crit :
>>=20
>> > Ingress is before vlans handler so these features and the
>> > NETIF_F_HW_VLAN_TX flag seem useful for ifb considering
>> > dev_hard_start_xmit() checks.
>>=20
>> OK, here is v2 of the patch then, thanks everybody.
>>=20
>>=20
>> [PATCH v2 net-next-2.6] ifb: add performance flags
>>=20
>> IFB can use the full set of features flags (NETIF_F_SG |
>> NETIF_F_FRAGLIST | NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA) =
to
>> avoid unnecessary split of some packets (GRO for example)
>>=20
>> Changli suggested to also set vlan_features,
>=20
> He also suggested more GSO flags of which especially NETIF_F_TSO6
> seems interesting (wrt GRO)?

I think at least TSO6 would very much be appropriate here.
