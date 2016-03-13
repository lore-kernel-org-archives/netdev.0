From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v4 00/11] add support for new
 ETHTOOL_xLINKSETTINGS ioctls
Date: Sun, 13 Mar 2016 17:30:20 +0000
Message-ID: <1457890220.3331.41.camel@decadent.org.uk>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hntg35Ye+Z7IO1TZOkQo"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40994 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbcCMRa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 13:30:27 -0400
In-Reply-To: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hntg35Ye+Z7IO1TZOkQo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-11 at 09:58 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> This adds support for the new ETHTOOL_xLINKSETTINGS ioctls. This also
> fixes a few compilation warnings as well as a heap corruption bug.
[...]

Patches 1-7: applied, thanks.

Patch 8: this breaks builds from tarballs as you didn't list the new
header as a source in Makefile.am.

Patch 9: I applied an equivalent change already.

Patch 10: still to be reviewed, but I will probably do so later today.

Patch 11: you need to answer my question about this.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-hntg35Ye+Z7IO1TZOkQo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5aOsAAoJEOe/yOyVhhEJbs4QAJKG2IoWwf//MFBeXJOfMGxS
Muqs1T01UhmvXx1FCblhOIKZcXm1mnW+SfxTX47SZIKHdisfNRni3or26zoVy2EL
ifIfqcZOGaP/F9KA3BhFJITBVA/MwY7d5wMt7nP/I04zWxXFxaAWwShQoDZZpQ/K
HY7DoOaREGLBJJuVnbxkCNDkav8QQxyCZQ5mGjhtjR1l6oT5tPLvIg4K/VHnOxRD
O6m06HT5MtvWkOFWOJJIe7riBhbhLzVSLGIbc26ijMNkjbd2TRfPcII1mlN+L02w
3sg1x8+7U0xzel/ux6+KpzGvBdmqrwAd4A06oj8jQQysFY81hFQ49Wx2DRq1SloR
T41fqLFgtgFikwQ71TF+mh+0GcktyemenAwt00uG35ZazL7MuErYsHaJs69QAIub
5Xcp424rpxNc0o2LTzngCyA+Wmr4arwp5axZ5Q6iy6aklUOZ8jTpl57m+COetfbi
ZKiLmtxAnR3h8Va/r0i2kqdc4Cjpv03Gag3WIXYG5JoMJM+a6xe5k1+cgNxLhbMn
N5QtZwAdXUPn1BdE2/GBDF2h4J/lWITk65qTbEgPV7uFwzegNIfAeBtfKxIPA/0o
W6YwYG6/wjr8Txzh783lIjJPUqvKS/51O8NXUJuPAtk4HdCpwDZ9D1Kiv3UErXun
Eo8yKWKZe2F1ex7zxh0S
=24fM
-----END PGP SIGNATURE-----

--=-hntg35Ye+Z7IO1TZOkQo--
