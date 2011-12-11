From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: IFB and bridges
Date: Sun, 11 Dec 2011 17:38:00 -0500 (EST)
Message-ID: <20a26951-0f6c-46f4-9acd-85d0e60cd114@jasiiieee>
References: <1323593906.4016.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:57978 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab1LKVhj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 16:37:39 -0500
In-Reply-To: <1323593906.4016.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Eric Dumazet" <eric.dumazet@gmail.com>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: netdev@vger.kernel.org
> Sent: Sunday, December 11, 2011 3:58:26 AM
> Subject: Re: IFB and bridges
>=20
> Le samedi 10 d=C3=A9cembre 2011 =C3=A0 20:15 -0500, John A. Sullivan =
III a
> =C3=A9crit :
> > Hello, all.  This is more an "out of curiosity" question.  I'm
> > starting
> > to build a test environment for all I've learned about Linux
> > traffic
> > shaping over the last week.  One of the devices happens to be
> > configured
> > as a bridge.  It quickly became apparent that I needed to do
> > shaping on
> > the individual ports and not the bridge port.
> >=20
> > This would be a real pain if I have lots of ports - 8 or 10 or 20
> > identical configurations.  Would this be an ideal use for IFB? That
> > is,
> > to redirect all ports to IFB and apply one set qdiscs/classes?
> > Thanks -
>=20
> I have no idea what your problem is.
>=20
> You want to shape either egress or ingress, for different reasons
> (most
> people shape egress), but on proxies an ingress and egress
> combination
> is welcomed.
>=20
> But having to use ingress on the same machine in place of egress, I
> dont
> see why.
>=20
>=20
>=20
>=20
>=20
I know IFB is often used for ingress but I wasn't really thinking of in=
gress filtering.  Let's say I have a 12 port Linux switch.  If any of t=
he ports become backlogged, I want them to prioritize time sensitive tr=
affic so I implement traffic shaping but I don't want to have to define=
 my qdiscs, classes, and filters 12 times over if they are all the same=
=2E  So I would direct each port to an IFB (not sure if that's intolera=
ble overhead), have a single set of qdiscs, classes, and filters, and, =
once those are applied, the packet arrives back on the same interface a=
nd proceeds assuming if has not been dropped or delayed. - John
