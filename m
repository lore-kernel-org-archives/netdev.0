From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Wed, 2 Dec 2009 18:34:51 +0100
Message-ID: <20091202183451.173db5f2@houba>
References: <20091128010156.1219012a@houba>
	<alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
	<20091130195004.38dbc319@houba>
	<alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
	<20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
	<20091201211945.505d3c98@houba>
	<alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
	<20091202085925.472136e2@houba>
	<alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
	<20091202154403.GB30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:40161 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018AbZLBRfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 12:35:16 -0500
In-Reply-To: <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 2 Dec 2009 18:05:24 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> > > In one of the cases, also the sg end dies (the 4th case). I
> > > suppose that was running earlier kernel already?
> >=20
> > This case was the one with tcp_frto=3D2 and tcp_timestamps=3D0 on h=
ouba.
>=20
> I suppose we're confused, I was refering to .4. case, did you perhaps
> mix that up with the latest set of tests which yields .8.?

You're right, I was talking about .8

> In the recent work, the most suspicious things are the new timeout
> things, I'll read them through once I've some time (but so far I've
> not found anything wrong in them but I of course can miss something
> subtle). ...I've added Damian as CC if he has some idea. If you want
> you can try with a trivial revert of that stuff, I've included a
> patch for that below.

I will try it.=20

I just discover something not good. I use tuxonice[1] branch on houba
for 2.6.32*.
Although my 2.6.31 kernel is vanilla[2].

[1] git://git.kernel.org/pub/scm/linux/kernel/git/nigelc/tuxonice-head.=
git
[2] git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.gi=
t

Now, I'm gonna go compile kernels again and again and make more
tests ... :)

--=20
=46r=C3=A9d=C3=A9ric Leroy
