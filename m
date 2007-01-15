From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Remove CONFIG_NET_WIRELESS
Date: Mon, 15 Jan 2007 13:31:06 +0000
Message-ID: <1168867866.3344.3.camel@johannes.berg>
References: <45A91414.40107@gmail.com>
	 <1168860268.3344.0.camel@johannes.berg>  <45AB79D1.2070002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-eCspZDEeqlLW78YTPYK2"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43214 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323AbXAONbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 08:31:17 -0500
To: Maarten Lankhorst <m.b.lankhorst@gmail.com>
In-Reply-To: <45AB79D1.2070002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eCspZDEeqlLW78YTPYK2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-01-15 at 13:55 +0100, Maarten Lankhorst wrote:
> Johannes Berg schreef:
> > On Sat, 2007-01-13 at 18:17 +0100, Maarten Lankhorst wrote:
> >  =20
> >> Remove CONFIG_NET_WIRELESS
> >> Nothing uses this, and it breaks the kernel build if a wireless device=
 is used with a unsupported type of bus.
> >> Verified this with a grep.
> >>    =20
> >
> > I don't really care about the symbol and I'm in favour of removing it i=
f
> > it is useless, but I don't understand the rationale. How does enabling
> > this cause anything to fail?
> >
> > johannes
> >  =20
> Enabling this doesn't cause anything to fail, but my wireless router
> doesn't have a pci bus, but instead a native SSB, so CONFIG_NET_WIRELESS
> isn't selected. This in turn causes wext-common.o to not be built, so I
> get missing symbols and a build breakage. That's why I made
> wext-common.o depend on CONFIG_WIRELESS_EXT instead of
> CONFIG_NET_WIRELESS. Since nothing else uses CONFIG_NET_WIRELESS I
> decided to kill that symbol.

Ok, that makes sense to me. Let's put this in but with this better
description rather than the original one.

johannes

--=-eCspZDEeqlLW78YTPYK2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFq4Ia/ETPhpq3jKURAoX2AJ9361hUvtrhSsTbZ5fRXtjTiri7ZACfWnJT
3lC8kr7ktxeQ2FJaccoKkaQ=
=N5vj
-----END PGP SIGNATURE-----

--=-eCspZDEeqlLW78YTPYK2--

