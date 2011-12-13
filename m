From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: TCP fast retransmit
Date: Tue, 13 Dec 2011 15:59:17 +0100
Message-ID: <201112131559.17969.carsten@wolffcarsten.de>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de> <53E23320-FE3E-4B9C-95FA-132F75E89E83@mpi-bpc.mpg.de> <1323786660.2744.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:34433 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab1LMO7n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 09:59:43 -0500
In-Reply-To: <1323786660.2744.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 December 2011, you wrote:
> Le mardi 13 d=C3=A9cembre 2011 =C3=A0 15:05 +0100, Esztermann, Ansgar=
 a =C3=A9crit :
> > On Dec 9, 2011, at 17:31 , Eric Dumazet wrote:
> > >>> It seems you have a lot of packet reorders.
> > >>>=20
> > >>> Are you using multipath or some channel bonding ?
> > >>=20
> > >> Not that I am aware of (i.e. not on our end). However, the conne=
ction
> > >> will probably routed through a firewall. I will have to check if=
 it is
> > >> configured to avoid reordering.
> > >=20
> > > Is it a linux based firewall ?
> >=20
> > No, it's Cisco.
>=20
> OK
>=20
> You could increase /proc/sys/net/ipv4/tcp_reordering from 3 to 16
>=20
> (Not sure it will change anything, since its kinda dynamic for a tcp
> session)

It's dynamic, but the sysctl changes the dynamic a lot, because its the=
=20
minimum value of the dupack threshold. Be sure not to set this too high=
, or=20
you will risk a lot of RTOs, which should kill performance even more=20
thoroughly.

Carsten
