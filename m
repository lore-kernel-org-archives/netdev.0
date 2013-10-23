From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 17:57:18 +0200
Message-ID: <4147596.bk6j0PMJyl@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de> <1382529601.7572.2.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49346 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751208Ab3JWP5V convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 11:57:21 -0400
In-Reply-To: <1382529601.7572.2.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 23. Oktober 2013, 05:00:01 schrieb Eric Dumazet:
> On Wed, 2013-10-23 at 13:33 +0200, Wolfgang Walter wrote:
> > I don't know what this value actually means. But on 3.4.x it is muc=
h
> > higher. On a machine with 512MB ram it is 32768, on a machine with =
1GB
> > ram it is 262144 and with 16GB ram it is 4194304.
>=20
> Such huge values should not be needed. We should have at most one dst
> per packet in flight.
>=20
> On a loaded router, a NIC not using BQL could queue around 16,000
> packets.
>=20
> Of course, Qdisc layers could also store a lot of packets, but using =
the
> default pfifo_fast is only adding 1000 packets per interface.
>=20
> I guess using 65536 as the default value should be safe and reasonabl=
e
>=20
> Have you tried using 32768 or 65536 ?

I use 32768 on routers with 512MB. They usually have around 50 ipsec-tu=
nnels=20
and only about 10 interfaces including vlan-interfaces.

On larger ones I set the bigger values from 3.4.x. That one with 16GB h=
as=20
about 2000 ipsec-tunnels. It has about 80 interfaces (inlcuding vlan-
interfaces). Physically it has 8 interfaces with together about 30 hard=
ware-=20
queues.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
