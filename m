From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 2/2] Use htobe64, htobe16 from libc instead of
 local byteswap code
Date: Mon, 21 Apr 2014 22:18:48 +0100
Message-ID: <1398115128.3624.142.camel@deadeye.wl.decadent.org.uk>
References: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
	 <1396494376-6521-2-git-send-email-crrodriguez@opensuse.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qVAMrlqG+l13g4NwDai+"
Cc: netdev@vger.kernel.org
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51183 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752896AbaDUVS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 17:18:59 -0400
In-Reply-To: <1396494376-6521-2-git-send-email-crrodriguez@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qVAMrlqG+l13g4NwDai+
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

--=-qVAMrlqG+l13g4NwDai+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WLOOe/yOyVhhEJAQpaow//TF0yzlnoB3d+KiYt21TVkSjmGRN7p8zn
igIbZr7+djipxwyQV124E7as72cvyDCPNrQ8LoC96NjPJKjL4QwpVh2TQe4A5YUl
VpCBorzNPJqcEKTEV43PzL3I7hQtaEZe05q9nN2aH2Ql0v9fwo6ZiJR/2i6iQL/x
CLjZa3bHbxLyslbj0n/7UiIiFn2kYdhrqJkSsJ/tEKgWrZR92EDcJza4lTsAZPza
a3+psTZT+Aty0SpNFuUI2h1LCD2qVJYoa0aK5pFpHMzxNyBbpwdXFXE4bwznwCbD
Z7T/oLAhlown9D9iExRhM1NR6koQqPf7MqNjJv5hkC7SCuLT54Rq1zmke/kZ9Oc3
JTyGC0ISZ3YKi9hsqGXZjDRlEh69q4mGC60CqGApJGIbC2t77B7YsBnjEf59JYkm
ELa4twc/qMMHhGg1nQB49TWBYDWEWDXTojTgonyi/BQNw2YoUchzIzM+mK0UftC/
oKiKmevYSTW9aVV2eKh3uCco0JHTtO2DJjQSfze160dAUrJmA38xilLTF0NRLCg6
iT1wX712MTgOUG+dB2eyOMgoGbotOzM7EuTpKiZp1PXbsn8i4f3sTZuPFt+Pg8FE
SYfnO2rlVbF/QXr2ubXsHTaOvK9TiFAT4LirsQMW89ctL1vpAnXfjQzkCiEEW/Ip
9glNiyFFIyI=
=N2Dv
-----END PGP SIGNATURE-----

--=-qVAMrlqG+l13g4NwDai+--
