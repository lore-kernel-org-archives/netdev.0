From: Eric Leblond <eric@inl.fr>
Subject: Re: panic on rmmod of nf_conntrack_irc
Date: Tue, 14 Apr 2009 22:46:40 +0200
Message-ID: <1239742000.24204.9.camel@ice-age>
References: <20090410191736.21efab8c@mako-desktop>
	 <49E4744D.5090205@trash.net>	<49E47C2D.1050508@cosmosbay.com>
	 <49E47EA5.3060706@trash.net> <20090414211946.4ea0455e@mako-desktop>
	 <49E4EE9C.7040509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-KoKp9vY0SOtVaCnm3HmS"
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Patrick McHardy <kaber@trash.net>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([91.121.73.151]:50817 "EHLO
	ks301150.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbZDNUuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 16:50:20 -0400
In-Reply-To: <49E4EE9C.7040509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KoKp9vY0SOtVaCnm3HmS
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi,

Le mardi 14 avril 2009 =E0 22:14 +0200, Eric Dumazet a =E9crit :
> Mariusz Kozlowski a =E9crit :
> > On Tue, 14 Apr 2009 14:16:37 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> >=20
> >> Eric Dumazet wrote:
> >>> Patrick McHardy a =E9crit :
> >>>> Mariusz Kozlowski wrote:
> >>>>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of
> >>>>> call_rcu()
> >>>> Thanks for the report. Does this patch fix it?
> >>>>
> >>> Hi Patrick, sorry for the delay, I was in holidays.
> >> No problem, me too :)
> >>
...

>=20
> Check commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
>=20
> netfilter: use a linked list of loggers

...

> Signed-off-by: Eric Leblond <eric@inl.fr>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20
> It seems "struct list_head        list[NFPROTO_NUMPROTO];" is not initial=
ized in "struct nf_logger" ?
>=20
> Please try following patch ?

I've just tested your patch. Without it, I was able to trigger the bug
(modprobe ebt_ulog ; rmmod ebt_ulog). All run cleanly with it.

All my apologies for having forgot to do this test.

BR,
--=20
Eric Leblond <eric@inl.fr>
INL: http://www.inl.fr/
NuFW: http://www.nufw.org/

--=-KoKp9vY0SOtVaCnm3HmS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Ceci est une partie de message
 =?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJ5PYtnxA7CdMWjzIRAv85AJsH8FxtF/xeSQqSYLOH0H8SAlTjngCfeuJW
XHMd3z9oPyOtTEJ+jezdJRM=
=83kK
-----END PGP SIGNATURE-----

--=-KoKp9vY0SOtVaCnm3HmS--

