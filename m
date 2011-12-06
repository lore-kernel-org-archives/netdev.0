From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 06 Dec 2011 03:39:56 -0500 (EST)
Message-ID: <03369d06-ee52-4eef-a8b6-5a21e6d56840@jasiiieee>
References: <1323152942.2467.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:64288 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121Ab1LFHjf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 02:39:35 -0500
In-Reply-To: <1323152942.2467.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Eric Dumazet" <eric.dumazet@gmail.com>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: netdev@vger.kernel.org
> Sent: Tuesday, December 6, 2011 1:29:02 AM
> Subject: Re: Latency difference between fifo and pfifo_fast
>=20
> Le mardi 06 d=C3=A9cembre 2011 =C3=A0 07:02 +0100, Eric Dumazet a =C3=
=A9crit :
> > Le lundi 05 d=C3=A9cembre 2011 =C3=A0 23:10 -0500, John A. Sullivan=
 III a
> > =C3=A9crit :
> > > Hello, all.  We are trying to minimize latency on our iSCSI SAN.
> > >  The
> > > network is entirely dedicated to the iSCSI traffic.  Since all
> > > the
> > > traffic is the same, would it make sense to change the qdisc for
> > > that
> > > interface to fifo from the default pfifo_fast or is the latency
> > > difference between the two completely negligible? Thanks - John
> >=20
> > A very small difference indeed. How many packets per second are
> > expected ? What kind of NIC are you using ?
> >=20
>=20
> To really remove a possible source of latency, you could remove qdisc
> layer...
>=20
> ifconfig eth2 txqueuelen 0
> tc qdisc add dev eth2 root pfifo
> tc qdisc del dev eth2 root
>=20
>=20
>=20
>=20
Really? I didn't know one could do that.  Thanks.  However, with no que=
ue length, do I have a significant risk of dropping packets? To answer =
your other response's question, these are Intel quad port e1000 cards. =
 We are frequently pushing them to near line speed so 1,000,000,000 / 1=
534 / 8 =3D 81,486 pps - John
