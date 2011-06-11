From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Sat, 11 Jun 2011 09:09:53 +0200
Message-ID: <20110611070952.GA24330@one.firstfloor.org>
References: <1307600810.3980.85.camel@edumazet-laptop> <1307664235.17300.44.camel@schen9-DESK> <20110609.204330.2090335955971650557.davem@davemloft.net> <1307745190.17300.85.camel@schen9-DESK> <BANLkTikU_ug=zUdfOZAX6eJ+BD9ZZvDrJA@mail.gmail.com> <1307768052.2872.50.camel@edumazet-laptop> <BANLkTim4ikjYJjdW8AWjmPi8hx-a0nh=Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:32928 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab1FKHJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 03:09:56 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTim4ikjYJjdW8AWjmPi8hx-a0nh=Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 02:17:24PM +0800, Changli Gao wrote:
> On Sat, Jun 11, 2011 at 12:54 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Le samedi 11 juin 2011 =E0 08:54 +0800, Changli Gao a =E9crit :
> >
> >
> > Whole point of the exercice is to prepare ground for routing cache
> > removal :)
> >
> > If you want a server being hit by millions of clients around the wo=
rld,
> > routing cache is a real pain because of memory needs.
> >
>=20
> Yes. I know the routing cache removal is our goal. But for his
> scenario, there aren't so many routing cache entries, so routing cach=
e
> may be a better option currently. However, if he just wants to

The routing cache has terrible cache line bouncing in the reference
count too.

-andi
