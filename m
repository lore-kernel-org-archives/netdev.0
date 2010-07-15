From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net/core: neighbour update Oops
Date: Wed, 14 Jul 2010 18:02:46 -0700 (PDT)
Message-ID: <20100714.180246.39175076.davem@davemloft.net>
References: <734423.1943.qm@web52004.mail.re2.yahoo.com>
	<1279035511.2634.456.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdkehn@yahoo.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54315
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757942Ab0GOBCb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 21:02:31 -0400
In-Reply-To: <1279035511.2634.456.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Jul 2010 17:38:31 +0200

> Le mardi 13 juillet 2010 =E0 08:23 -0700, Doug Kehn a =E9crit :
>> When configuring DMVPN (GRE + openNHRP) and a GRE remote
>> address is configured a kernel Oops is observed.  The
>> obserseved Oops is caused by a NULL header_ops pointer
>> (neigh->dev->header_ops) in neigh_update_hhs() when
>>=20
>> void (*update)(struct hh_cache*, const struct net_device*, const uns=
igned char *)
>> =3D neigh->dev->header_ops->cache_update;
>>=20
>> is executed.  The dev associated with the NULL header_ops is
>> the GRE interface.  This patch guards against the
>> possibility that header_ops is NULL.
>>=20
>> This Oops was first observed in kernel version 2.6.26.8.
>>=20
>> Signed-off-by: Doug Kehn <rdkehn@yahoo.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
