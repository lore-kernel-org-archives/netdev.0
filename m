From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use batched device unregister in
 veth and macvlan
Date: Mon, 09 May 2011 11:42:00 -0700 (PDT)
Message-ID: <20110509.114200.226765786.davem@davemloft.net>
References: <BANLkTim2e1Gm_jqfY89is-FfRYTu2=G02w@mail.gmail.com>
	<1304929236.3342.8.camel@edumazet-laptop>
	<1304932677.3342.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, alex@alex.org.uk, netdev@vger.kernel.org,
	jesse@nicira.com, paulmck@linux.vnet.ibm.com,
	greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54127
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751476Ab1EISmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:42:33 -0400
In-Reply-To: <1304932677.3342.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 May 2011 11:17:57 +0200

> veth devices dont use the batched device unregisters yet.
>=20
> Since veth are a pair of devices, it makes sense to use a batch of tw=
o
> unregisters, this roughly divides dismantle time by two.
>=20
> Fix this by changing dellink() callers to always provide a non NULL
> head. (Idea from Micha=A9=A9 Miros=A9=A9aw)
>=20
> This patch also handles macvlan case : We now dismantle all macvlans =
on
> top of a lower dev at once.
>=20
> Reported-by: Alex Bligh <alex@alex.org.uk>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
