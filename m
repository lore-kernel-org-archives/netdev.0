From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 00/14] ethtool: Improve documentation
Date: Wed, 12 Feb 2014 22:13:04 +0000
Message-ID: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Vl2lKyN11NPacvLQOJDZ"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52772 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752700AbaBLWNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:13:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vl2lKyN11NPacvLQOJDZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This series converts most comments in <linux/ethtool.h> into kernel-doc
format, and expands them to describe the semantics as well as I
understand them.  It also fixes some kernel-doc formatting errors.

I started on this at Solarflare, but they graciously allowed me to take
it away and finish it off.

Ben.

Ben Hutchings (14):
  ethtool: Expand documentation of struct ethtool_cmd
  ethtool: Expand documentation of struct ethtool_drvinfo
  ethtool: Expand documentation of struct ethtool_wol
  ethtool: Expand documentation of struct ethtool_regs
  ethtool: Expand documentation of struct ethtool_eeprom
  ethtool: Expand documentation of struct ethtool_ringparam
  ethtool: Update documentation of struct ethtool_pauseparam
  ethtool: Expand documentation of string set types
  ethtool: Expand documentation of struct ethtool_test
  ethtool: Expand documentation of struct ethtool_stats
  ethtool: Expand documentation of struct ethtool_perm_addr
  ethtool: Document the general convention for VLAs in kernel space
  ethtool: Move kernel-doc comment next to struct ethtool_dump
    definition
  ethtool: Fix unwanted section breaks in kernel-doc

 include/linux/ethtool.h      |   3 +
 include/uapi/linux/ethtool.h | 439 ++++++++++++++++++++++++++++++++-------=
----
 2 files changed, 329 insertions(+), 113 deletions(-)


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-Vl2lKyN11NPacvLQOJDZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvx8Oe/yOyVhhEJAQokEg//bZu59ghVXRmrSkN77EJ8ZSWEOOVU+H4F
+vQmB88OQsc/Z1R2lW7EXVtOkJMzWcJGfVc9o0JLwZcfiDiyqvECUUIMWuAFsBUk
HTFv6HLYqdCfEDPw8jJVlfhBdIl6WNR558aYnRK8snw6T9r28yu0XPXUoca64hqo
JcmbA80PR3zID12TkJ76b/wQr4egF1+nzLCDym1P+pmfCMPrWtr8sHFo68qlkeRC
z2HJw/UWGXJRx3DNGJDvbqJFNWmiccI6kSKtKFwKnE/PW/OlzHDdOmMd+KcvGvTy
tGQ6nnYWcv00jOyEMJVbYoYqbwwjZcm1Jn/67dfQ0tRI4JYtVJ68B2Wo5wRsdTB1
IVPKdydhWM8SZs5c8fIqIz0pnkEjDHPZk5I5OfvTo+n3UwfFo48s9IkEzfohTruc
fBfs5N3uQcBmHcrSkw0rBqBFYS3PeD0zYpWmp6J68RoHlu468PmgiN33EBjia8Bp
zs37ihWmlQeSoB6GuSluMVU7NWyx0d1CEeUP39dG0u14nI8mUJDr0PTBsdgG0sBR
v4aFZn0goyuBAVVWHQQ2KBu4fNUwfokkTp+APkWY3SNHyBe3rEVsVIHIfGKAnO0t
FwDJ38nXT8ps0FbZvkon+Y/97/VcZuqVmoGD8aOuG6hrYa64t5nPtXMxC+h/v38e
lIhLQ5OtCx0=
=iDzR
-----END PGP SIGNATURE-----

--=-Vl2lKyN11NPacvLQOJDZ--
