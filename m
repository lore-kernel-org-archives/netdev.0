From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: drivers/net: Kconfig & Makefile cleanup
Date: Tue, 22 Nov 2011 06:48:32 +0000
Message-ID: <1321944512.2839.219.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-n+mTcrKsMYpjNUD+IyMh"
Cc: netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54175 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754208Ab1KVGsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 01:48:41 -0500
Received: from [2001:470:1f08:1539:21c:bfff:fe03:f805] (helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <ben@decadent.org.uk>)
	id 1RSk9n-0003RR-5p
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 06:48:39 +0000
Received: from ben by deadeye with local (Exim 4.77)
	(envelope-from <ben@decadent.org.uk>)
	id 1RSk9h-0001DB-2r
	for netdev@vger.kernel.org; Tue, 22 Nov 2011 06:48:33 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-n+mTcrKsMYpjNUD+IyMh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You wrote that (some time ago now):
> As a side cleanup, found that the arcnet, token ring, and PHY
> Kconfig options were a tri-state option and should have been
> a bool option.

How did you decide that?  This seems to be correct for TR, but ARCNET
and PHYLIB each select some support code that can be built as a module
(and which has been, in Debian).

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.


--=-n+mTcrKsMYpjNUD+IyMh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATstFwOe/yOyVhhEJAQo53xAApvTc8THKbFryLL2PaeQR9tnoPItLAauq
/jqPn2uVemviNr8DGIkgZGLxSQQaBcgm5oHimUY5MjX7zx2Y4+tJNxGYUvA6RUvh
yhXqRrA3X2gy7eqsCZAufa46liuvoDKMZblfK3SiwaiaaR/BnR6RrufSL+8reQ2O
a4QFwFjWsffse8rFO/aabJ0Il7NB9x4YBwl00UvhNgdPxxwKRkARO4Kn8fCjwZJs
2bBtRR/oQfmQeV6QVG9s0Jv/a6/bjtAM5hbVxOZSThNl9DenuceKgc4dFosrzMPY
Qk2pJlNDX/JciFr+vhSC+Nd25OEZFwZPvHFsxyJQxx1T2Q90dnSC5tPgyhwFOgI3
Xy+mCybrFWgNqXpTK/IYBLOY0SoAVLukT1+UXPD4cnnLSb2Yvdk1fbAXudrzKGP3
njREZMDLCf18YnYR8BqytyQTEl4SR77Yv5gyvAbHH29QPr5garUYFHd+3OX5tsUc
pzgYUBbCopg3DoSrf+XdbYtsyil6P9n0XhCuM36abbAZnA1iemLTvuICAxTlq5t+
gbTzKyR3hlVljPU6BzBLhCNRrd4sgsN5J40Frk8qPi0LVvkGGoQYUfBjK/CDxAOr
rBjYM+3IK2cG9muMSJ1LVqN1CeDndCi0RlvyRKJ3p6Me8SpsGLmNmjMd4Nvz2HNG
vypekFSmaIc=
=CnHc
-----END PGP SIGNATURE-----

--=-n+mTcrKsMYpjNUD+IyMh--
