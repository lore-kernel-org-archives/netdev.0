From: Alpt <alpt@freaknet.org>
Subject: Ipv6 and the lost broadcast
Date: Fri, 31 Dec 2004 23:31:12 +0100
Message-ID: <20041231223112.GA6134@darkalpt>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qDbXVdCdHGoSgWSk"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Once upon a time in the ip protocol there was INADDR_BROADCAST, and all
seemed happy.

=66rom "man ipv6":
" IPv6 supports several address types: unicast to address a single host,
  multicast  to  address a group of hosts, anycast to address the nearest
  member of a group of hosts (not implemented in Linux),
  IPv4-on-IPv6  to address a IPv4 host, and other reserved address types."

=66rom  net/ipv6/tcp_ipv6.c +582:
=2E..
	/*
  	 *	connect() to INADDR_ANY means loopback (BSD'ism).
  	 */
  =09
  	if(ipv6_addr_any(&usin->sin6_addr))
		usin->sin6_addr.s6_addr[15] =3D 0x1;=20
=2E..

Why it isn't supported? Is there a particular reason to follow this
BSD'ism?=20

Is it possible to achieve the same result of INADDR_BROADCAST with
multicast? The propagation has to be restricted only to the neighbour
nodes.


Best Regards
--=20
:wq!
"I don't know nothing" The One Who reached the Thinking Matter   '.'

[ Alpt --- Freaknet Medialab ]
[ GPG Key ID 441CF0EE ]
[ Key fingerprint =3D 8B02 26E8 831A 7BB9 81A9  5277 BFF8 037E 441C F0EE ]

--qDbXVdCdHGoSgWSk
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFB1dMwv/gDfkQc8O4RApdjAJ45hCKiV9673qrR0n/cUZFYAybqHQCgp/MA
lqc74S9l3p60u1r3SmHPywE=
=qMh9
-----END PGP SIGNATURE-----

--qDbXVdCdHGoSgWSk--
