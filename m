From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 23:03:39 +0100
Message-ID: <20091203230339.56a613e1@houba>
References: <20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
	<20091201211945.505d3c98@houba>
	<alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
	<20091202085925.472136e2@houba>
	<alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
	<20091202154403.GB30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
	<20091202183451.173db5f2@houba>
	<4B16BD58.3040802@tvk.rwth-aachen.de>
	<20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
	<4B17A791.80808@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
	<4B17C6C3.1060000@tvk.rwth-aachen.de>
	<20091203202328.62d7551a@houba>
	<4B1820B8.7050500@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:49074 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbZLCWD5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:03:57 -0500
In-Reply-To: <4B1820B8.7050500@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thu, 03 Dec 2009 21:34:00 +0100,
Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :

> Frederic Leroy schrieb:
> > Le Thu, 03 Dec 2009 15:10:11 +0100,
> > Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :
> >>> I suppose adding || !tp->retrans_stamp into the false condition i=
s
> >>> fine as long as we don't then have a connection that can cause a
> >>> connection to hang there forever for some reason (this needs to b=
e
> >>> understood well enough, not just test driven in stables :-)).
> >>>
> >>>> Unluckily, I still cannot reproduce the scp stalls here, so it
> >>>> would be nice if Frederic printed retrans_stamp together with
> >>>> icsk_ca_state and icsk_retransmits, please.
> >>> It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
> >>> that might have some significant w.r.t what happens because of
> >>> FRTO.
> >> I made a patch for Frederic with Codebase
> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.g=
it
> >>
> >> Thanks for testing.
> >=20
> > I made a new .11 trace with damian patch.
> > The copy went to the end.=20
>=20
> Ok, at least this "fix" seems to work at first glance, but the printk
> is quite useless now. Could you run another test with the printk's bu=
t
> without the retrans_stamp =3D=3D 0 check, please?

Done, it's .13

It stalled.

I only manage to make a failing stream only once. It seems
after 23h the network is not interferenced.

--=20
=46r=C3=A9d=C3=A9ric Leroy
