From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 00:50:11 -0700 (PDT)
Message-ID: <20110705.005011.1268380726966376331.davem@davemloft.net>
References: <1309846875.2720.43.camel@edumazet-laptop>
	<4E12B5A6.2020802@inliniac.net>
	<1309849214.2720.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab1GEHuR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:50:17 -0400
In-Reply-To: <1309849214.2720.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jul 2011 09:00:14 +0200

> Le mardi 05 juillet 2011 =E0 08:56 +0200, Victor Julien a =E9crit :
>=20
>> Is this still also true for IP fragments?
>>=20
>=20
> This point was already raised. IP fragments have rxhash =3D 0, obviou=
sly,
> since we dont have full information (source / destination ports for
> example)

I will fix this.

I will add an option to the fanout, as a flag bit to the setsockopt,
that will cause the fanout to act as a ip_defrag() agent and rehash
the packet once all the fragments arrive.

Since this will operate internally on the clones passed to AF_PACKET,
it will not have any effect on the original packets traversing through
the machine.
