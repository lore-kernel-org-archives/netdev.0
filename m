From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: IFB and bridges
Date: Sun, 11 Dec 2011 19:42:48 -0500 (EST)
Message-ID: <9ab07532-3d46-4e4a-8baf-5863b0cec5db@jasiiieee>
References: <1323640859.2576.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:49503 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566Ab1LKXmW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 18:42:22 -0500
In-Reply-To: <1323640859.2576.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Eric Dumazet" <eric.dumazet@gmail.com>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: netdev@vger.kernel.org
> Sent: Sunday, December 11, 2011 5:00:59 PM
> Subject: Re: IFB and bridges
>=20
> Le dimanche 11 d=C3=A9cembre 2011 =C3=A0 17:38 -0500, John A. Sulliva=
n III a >
> > I know IFB is often used for ingress but I wasn't really thinking
> > of
> > ingress filtering.  Let's say I have a 12 port Linux switch.  If
> > any
> > of the ports become backlogged, I want them to prioritize time
> > sensitive traffic so I implement traffic shaping but I don't want
> > to
> > have to define my qdiscs, classes, and filters 12 times over if
> > they
> > are all the same.  So I would direct each port to an IFB (not sure
> > if
> > that's intolerable overhead), have a single set of qdiscs, classes,
> > and filters, and, once those are applied, the packet arrives back
> > on
> > the same interface and proceeds assuming if has not been dropped or
> > delayed. - John
>=20
> Really ? How are you going to shape a single IFB device, if you
> really
> have independant 12 ports. (Its a switch, not a hub after all)
>=20
> A script can define your qdiscs/classes/filters hundred times, or one
> thousand times, and writing such a script is far more easier than
> setup
> IFB.
>=20
>=20
>=20
>=20
<grin> That's why I thought I'd ask the experts :) - John
