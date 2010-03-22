From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen node allocation
Date: Sun, 21 Mar 2010 20:37:44 -0700 (PDT)
Message-ID: <20100321.203744.43021126.davem@davemloft.net>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	<1268990933.3048.15.camel@edumazet-laptop>
	<19363.32154.39665.185451@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52905
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063Ab0CVDhW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 23:37:22 -0400
In-Reply-To: <19363.32154.39665.185451@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: robert@herjulf.net
Date: Fri, 19 Mar 2010 14:35:22 +0100

>=20
> Eric Dumazet writes:
>  > Le vendredi 19 mars 2010 =E0 09:44 +0100, Robert Olsson a =E9crit =
:
>  >=20
>  > I cannot understand how this can help.
>  >=20
>  > __netdev_alloc_skb() is supposed to already take into account NUMA
>  > properties :
>  >=20
>  > int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
>  >=20
>  > If this doesnt work, we should correct core stack, not only pktgen=
 :)
>  >=20
>  > Are you allocating memory in the node where pktgen CPU is running =
or the
>  > node close to the NIC ?
>=20
>  I didn't say it should help the idea was to give some hooks to=20
>  experiment and see effects with different node memory allocations.
>  There are many degrees of freedom wrt buses(device)/CPU/menory.

I think it's a useful feature and by default the netdev alloc
is still used, so... applied to net-next-2.6
