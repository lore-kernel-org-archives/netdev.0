From: Ben Hutchings <ben@decadent.org.uk>
Subject: [stable] netfilter: ipset: Check and reject crazy /0 input
 parameters
Date: Tue, 24 Dec 2013 03:00:04 +0000
Message-ID: <1387854004.2783.38.camel@deadeye.wl.decadent.org.uk>
References: <20131222015933.GA30757@nitrogen.neutroncom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RlsJQgUTyKdnDIOFRaN0"
Cc: Neutron Soutmun <neo.neutron@gmail.com>, 732689@bugs.debian.org,
	netdev <netdev@vger.kernel.org>, stable@vger.kerne.org
To: David Miller <davem@davemloft.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40847 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932254Ab3LXDAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 22:00:15 -0500
In-Reply-To: <20131222015933.GA30757@nitrogen.neutroncom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RlsJQgUTyKdnDIOFRaN0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This fix went into Linux 3.7:

commit b9fed748185a96b7cfe74afac4bd228e8af16f01
Author: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date:   Tue Sep 4 17:45:59 2012 +0200

    netfilter: ipset: Check and reject crazy /0 input parameters
   =20
    bitmap:ip and bitmap:ip,mac type did not reject such a crazy range
    when created and using such a set results in a kernel crash.
    The hash types just silently ignored such parameters.
   =20
    Reject invalid /0 input parameters explicitely.
   =20
    Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Should it also go into stable 3.x.y updates?  I checked that it applies
and builds cleanly on top of 3.2.53.

Ben.

--=20
Ben Hutchings
Unix is many things to many people,
but it's never been everything to anybody.

--=-RlsJQgUTyKdnDIOFRaN0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUrj4tOe/yOyVhhEJAQpSzhAAj9zbUu7nI75IdxvevfVViZL2OzA6+nsQ
4be5YdYipz7VXtBVqt/yjun/AGHgIRMYmvjWvxl44k71AnmDunQNsubhLirIuKwk
srAsjPh69sKiWFEcIft9BsmBTRqp9+x6TOax0XfIKIpTTvrMP16FrdPAFbOQwML6
TUkA0+6QreNRmLAuQpMd4YlgSBd3Hy1IOVdIg4yH2s10dOUChteu0wUOVnE436LB
wIcKptTQc7qG+Qocy9t6lHe+lx0dTHeZLjCwbjf8o+wwLcLSy2BgalDk0SxK9C0i
U1Mg4JWAAofqG32JRFu9sq8EEKCfe7hFptPzxuUjOpXf3vo5ZizdJUTsemOq8/ON
o4GPmSH9WK2pGlQTIVsZbFbYRc8bb3wyDrvFAF4DIGvC7+/5uRp1pL+owg5K4BvC
fwIIcZRQe/hEmAK1vwS9KBAcxHSXV0jo6lYaaSclMp1+aboynPff4FulJSuEYZZ1
dvrz0lCGb8yEM9/iaw2cZjMJUAGnZtDuZEK2XUI5sKnK9jx0Z4HKdWSRssRAGHp0
OgshywKfuA8uSIlkH4ulZTfLtHA4VgtjlPu+GRkc+fhGuLoC1+h+AUfoZ8BvwARg
R0gqjbKMRuCNJhvaewjSJMY2bEpKQvb1pHBXPf+29akEC/ugpI8Roxe+fI2behf0
Dk+rpU3gQhQ=
=60nv
-----END PGP SIGNATURE-----

--=-RlsJQgUTyKdnDIOFRaN0--
