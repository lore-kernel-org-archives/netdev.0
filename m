From: Mihai Moldovan <ionic@ionic.de>
Subject: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 03:22:33 +0200
Message-ID: <553EE0D9.3050601@ionic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="omWLQSGomcGOGAFojW85ilDWOLX6G8K4F"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from powered.by.root24.eu ([5.135.3.88]:48262 "EHLO Root24.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761AbbD1B1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 21:27:45 -0400
Received: from nopileos.local (home.ionic.de [217.92.117.31])
	by mail.ionic.de (Postfix) with ESMTPSA id A94B14F0904C
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 03:22:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--omWLQSGomcGOGAFojW85ilDWOLX6G8K4F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,

Following up a bug report I received at
http://bugs.x2go.org/cgi-bin/bugreport.cgi?bug=3D799 it looks like the cu=
rrent
version iproute2's ss utility always returns an empty result set whenever=

specifying the -u flag.

The problem has been bisected to 9db7bf15e22b6a1b8bc09c4a1e29571cbca55c94=
 and is
also affecting version 3.19.0, but most notably 4.0.0+.

I'm not quite sure that's the correct commit, but it does definitely look=
 related.

Even ss -xu, which previously returned a list of UNIX and UDP sockets now=

returns nothing on my systems.


Any help with that matter is greatly appreciated.



Mihai


--omWLQSGomcGOGAFojW85ilDWOLX6G8K4F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJVPuDZAAoJEB/WLtluJTqHoRcQAI1WEXrfsFeTDAnY5txSVUQF
lOT8K0tRda8JMKB1kgdl4vj9QZWtJY/ku9IYCJZBkhzyOHdJ+4L0Bmw3YC2vwmYO
Xhf7URcS34RhvRl0h0Yn/HU9Bd/cRBFRMblHBBTaHn8jQj3zIfEZnmcciz4tZGhd
01lkwkRKFxOOm2IUW6q+QK/YDIxuQ+T8unBL+bhvApcFB8SSXsqaHMS3DP0NpXyg
h17YA4QWMoW7tM64zu0DUJBXb09bReq6gh72lHuOOf6ciF964iWKu+1VOLE/xRwe
B8l8bq5eBgrI/LGFnkaYRiLXztfXzfeVV6OI+4uSMNdimz7sKYMzCPwC3utPM3Ir
Sxxjo6+OtQn8YuVjSE7aCZToJC7nbiJSyQ2Ij2xFDe9lPF/u7u2iVUoHJIdaePS7
u3LrkCOVzqr3HxfHZm4STHGmdtIVpmyt0e2Lp+xZA9NoiH3OkKKX8JvIn0AfYIEc
yjgtp0Fk6Tpt9ojLwq7thBYcvJKOqcjBtxuBKGBnrnzRtRGLoRaLc7NwZXAqzYoY
IPcxdWZpx9zpYZatTUiuQZ15BHe2056ivh38kcV9o3P3BxVCP2yFyPnMbyJ+NuKx
psKYpojm6aHL75vT550f5SSBoVeesm6HbP/nYGKQNg140D1HUi8/pMNZ56Q0yQLh
pC3pgOlP85MAqYdk8efg
=jSMn
-----END PGP SIGNATURE-----

--omWLQSGomcGOGAFojW85ilDWOLX6G8K4F--
