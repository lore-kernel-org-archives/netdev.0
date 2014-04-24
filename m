From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Thu, 24 Apr 2014 17:02:00 +0100
Message-ID: <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
	 <20140423153018.GA13717@breakpoint.cc>
	 <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
	 <20140423162712.GB13717@breakpoint.cc>
	 <20140424151748.GH1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HB1/9zdSEgBWZTo8fPUi"
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60716 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756860AbaDXQCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:02:17 -0400
In-Reply-To: <20140424151748.GH1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HB1/9zdSEgBWZTo8fPUi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-24 at 17:17 +0200, Hannes Frederic Sowa wrote:
> On Wed, Apr 23, 2014 at 06:27:12PM +0200, Florian Westphal wrote:
> > Ben Hutchings <ben@decadent.org.uk> wrote:
> > > Userspace can't assume it now because access is controlled by a sysct=
l.
> > >=20
> > > I think it is for distributions to choose whether to enable this feat=
ure
> > > in ping and the kernel.
> >=20
> > I am not (yet) buying this argument.
> >=20
> > Saying 'you need to change sysctl foo for this to work' in a program ma=
npage
> > is a lot different than 'you need to recompile the kernel'.
>=20
> Maybe we can make the Kconfig option depend on CONFIG_EMBEDDED so that we=
 can
> be sure people don't have man-pages on the device. ;)
>=20
> Seriously, I think doing authorization check based on gids in a sysctl is
> wrong.

It is quite weird but perhaps made sense in the context of some embedded
systems.

> Switching over to capabilities seems to make this interface much
> more useable to me. But we would need to make sure, that we don't suddenl=
y
> allow people to use those sockets where it was restricted previously.

Standard ping could already be implemented as setcap (CAP_NET_RAW).  You
want a capability just for ping?

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-HB1/9zdSEgBWZTo8fPUi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1k1eOe/yOyVhhEJAQpRBxAAuOD5Nu3Cn6GRdA7KlkTb10RtIdd79IbB
ixh3VWUoyLHV5YbGOipmrCsG9V5KFhSqYYh5rPSE7K01pyxjsN/0M0cVxKzOoXBk
iJhH/IlFpNDamc1PLeXnQAFBRh8KVTcBIAoUlEqJaYPfI59mF+e1MPoqsl/78lDN
KhYJVgoqCu8bOvlGMqX1xOOrz+w5ZyVu+xRO25687w6NCI8g4xIDWQogcyl8/QGZ
mf5h2KwLHg5jhXC8aevFWSt25krJrxD9+6SOxxJNFUWNDdlAmaufoC6KNw8KBbUD
36aXsnRLSm0gEYHQLgBpUR435tLHLenLSXzYpIyVm09QZcrfwFBeEcytQfTXAkOK
HbWyIt7+BEM1Fa5YG5SFZAKUhfwTRfJya+jJBKaEOKFWn2vXnzLgInfhTzNUmQ1X
yZHwnE7xd7WzxyZDsUdMrnbsLVruJq+icR16HSC9Rr2KsvN3WYFliIgHQ0xw34Sm
Y9I+9/9TEdWroKnY4W+tOtzieox1Q8Tabhnn4hntDFf/Bh+TEqJL9faiI0Nyayqp
0NiYvMWu6/rBbXC3looOcsiuYY8JyihGH5erTek1CBNg9fVaeEwd25sbfBBOFnvz
LRr2DQi1FxWS2rbnGqn7DgKqeFomltu+oEpO8OTuXjdOAWDloiQwbokebteeMBGT
h7P3qBCv9M4=
=Loea
-----END PGP SIGNATURE-----

--=-HB1/9zdSEgBWZTo8fPUi--
