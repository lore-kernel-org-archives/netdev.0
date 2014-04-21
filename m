From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 2/2] Use htobe64, htobe16 from libc instead of
 local byteswap code
Date: Mon, 21 Apr 2014 22:18:56 +0100
Message-ID: <1398115136.3624.143.camel@deadeye.wl.decadent.org.uk>
References: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
	 <1396494376-6521-2-git-send-email-crrodriguez@opensuse.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jx3nslj/FH0MuN6BwdQS"
Cc: netdev@vger.kernel.org
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51185 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754527AbaDUVTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 17:19:00 -0400
In-Reply-To: <1396494376-6521-2-git-send-email-crrodriguez@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jx3nslj/FH0MuN6BwdQS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-03 at 00:06 -0300, Cristian Rodr=C3=ADguez wrote:
> They are implemented in <endian.h> which is already included
> in internal.h, no need to reinvent them with different names.
>=20
> Signed-off-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
[...]

According to the manual page, "These functions were added to glibc in
version 2.9."

Which is quite old now, but newer than several supported distributions
(e.g. RHEL 5).  So we would need an autoconf test and fallback
definition, at which point there doesn't seem to be any benefit.

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-jx3nslj/FH0MuN6BwdQS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WLQOe/yOyVhhEJAQoK1A//bj+L25YYqlltWEiyAeVKggCHmH8naWLi
vyQu/xF8EQUstwzaAGxBlxgYG7L8ZcChruOJ30i+HtvzBqdh8NfbyKfmEIqkegP3
wr6etIk3X7IvUyt7ocLenUTcz/m+ApPgIBkVIxz7H9nOHlIQteqgkSvaMeuvUd+V
vFdaSYgD8SNI+eciMTvk1ehmRMrngGxtcrDN4KjE3UIOWGfmwBGqpLXG9EXdFR9q
4Zq3/vrbiXfqLjNR/BHlGtTo22s8Q2cA5TGgPQwAIcZ5tfl1GS/l7sfzALJA474e
MEdjJE1wK7lvIsy6trUhQXrk3sM9DPq5sw0TayKrmnpRjo0oOQs/W7k7m3HRBJ9/
AT0nukT6JQZFCCksU29b1Ons8CqLiqJzEKM8gE70nZ0nvISs7XGD0SKhelWeQEpl
ztq0/5uMBqdvGBoRIxXpts5B3o9VFcz2VHhICyxF06jVa1bAMizg8FOIK/QfOxpM
3x499hvrqPXoLzDrVtsAFPFomcjMSdmRTASQ2pHaK2s5ZP6MdfTXxu0TsZJ+bJ3C
mYyyI1dT1N89wM4ddLSSJH28bq9bfTJqCJ1JcQoJGXCgEildiZfYW/rZXzAyXzAu
rg65Jp+Ar4sQ4VC1Kd+Hl//rMhIEcOyOYtXixKfVcOASB+TGi77fxeT5TxGgVFOz
GLc4bJ4l3YE=
=5p3X
-----END PGP SIGNATURE-----

--=-jx3nslj/FH0MuN6BwdQS--
