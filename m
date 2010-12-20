From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 13:54:47 +0100
Message-ID: <1292849687.2800.27.camel@edumazet-laptop>
References: <4D0F0D73.2080807@itcare.pl>
	 <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
	 <1292836097.2800.3.camel@edumazet-laptop>
	 <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
	 <1292836885.2800.4.camel@edumazet-laptop>
	 <20101220103226.GB7977@ff.dom.local>
	 <1292841671.2800.11.camel@edumazet-laptop>
	 <20101220111141.GC7977@ff.dom.local> <20101220115855.GD7977@ff.dom.local>
	 <4D0F471D.8030607@itcare.pl>  <20101220122256.GA9325@ff.dom.local>
	 <1292849150.2800.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56823 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab0LTMyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 07:54:51 -0500
Received: by wyb28 with SMTP id 28so2808942wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 04:54:50 -0800 (PST)
In-Reply-To: <1292849150.2800.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 13:45 +0100, Eric Dumazet a =C3=A9=
crit :
> Le lundi 20 d=C3=A9cembre 2010 =C3=A0 12:22 +0000, Jarek Poplawski a =
=C3=A9crit :
> > On Mon, Dec 20, 2010 at 01:07:57PM +0100, Pawe=C5=82 Staszewski wro=
te:
> > > I have the same panic as without.
> > >
> > > This patch was added to clean 2.6.37-rc6 - without previous patch=
 for =20
> > > sch_generic.h
> > >
> > > Attached image with kernel panic.
> >=20
> > This one is definitely the nicest ;-)
>=20
> Indeed, we finally can see where it happens ;)
>=20

Shouldnt ifb adds some dev->features, like NETIF_F_FRAGLIST /
NETIF_F_SG ?


