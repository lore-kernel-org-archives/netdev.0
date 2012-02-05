From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] net: move ethtool include to where its used
Date: Sat, 4 Feb 2012 21:20:07 -0500
Message-ID: <201202042120.14192.vapier@gentoo.org>
References: <1328267822-25690-1-git-send-email-vapier@gentoo.org> <20120204.162331.1482938799603820869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1366969.LhVA2hoFlq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55859 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab2BECT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 21:19:57 -0500
In-Reply-To: <20120204.162331.1482938799603820869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1366969.LhVA2hoFlq
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Saturday 04 February 2012 16:23:31 David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> > The linux/mii.h headers has long been standalone for userspace.  But a
> > recent commit added linux/ethtool.h to the include list even when it
> > isn't used.  Since we only need this with __KERNEL__, move the include
> > down to the right spot.  Now userland no longer needs to pull this in.
>=20
> I don't understand what the problem is.

the exported linux/mii.h userspace code doesn't need linux/ethtool.h, thus =
it=20
should not need to include it

> linux/ethtool.h is a safely exported header file for userspace,
> so if linux/mii.h now starts to include it this should make no
> difference whatsoever for userspace unless userspace does something
> bogus which in turn would mean it's almost certainly userspace
> which is at fault here no the kernel headers.

by the same token, you could have linux/mii.h pointlessly include a lot of=
=20
other unused headers.  they're still unused and a waste.
=2Dmike

--nextPart1366969.LhVA2hoFlq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPLeddAAoJEEFjO5/oN/WBYygP/1KCeDQDLPnQ5udNt275p17f
hP5fSjUuPDSmmRaTX74J67wDtx+1U1d5lg/9I/HHa2iCf4UkrcAuW3LBykI7uFub
RekZeRVdeuyFgVRaEwyD3mmmKeggqVqY73MYdqKwqaIbtGVuMmgfb6+JE37rcw6K
rXx2ivOFMQL19bbeucXUXZrnGdXrcmYz8vSPzVYTHUxPvBmqVfyugQWbPCYm36d3
Wcax4ihVaJq/KrFgJp3ZmnSZPmi3OwL9wEGUhfekYXoTKMSkqE0/b36PHlxPkJKc
7IHGIMRf4R4Vs48obra/v9UF1rQZ6omBTrJQRvoLL/ln1WwzOtToj7YfRyRK6d5P
C6kkE29dIs6mzBuoJxODLLt+7yRKwMxdkmzqEmibhgI93VYxV5k8Aw9bG34Pq1XT
gPt/YSVraJh/h5r3c1csyqApcE4e9itfKPBPIPotlAOQYPygbBLILZMEYSgXEPH9
MMv/b1uSBM5vGm6Y9xmSOF7U7rEPMblLO76Z9ot4yoSY8P/7u2Zqb5e76F+NrLym
iqZ/uGhP3glFGG5KFXqNFBr9nel1dNUK1iJ/cNnF2delJgnpWsEfpKWXt3T7mTlO
PlPEZVnuEKBgK3oBqPybf5vvWnpnZQWf7ACwzhVsdR/T3jJzyed3/+cdrM4VdhSb
OcQoj3aO9YVGoBlhMuvM
=BA9u
-----END PGP SIGNATURE-----

--nextPart1366969.LhVA2hoFlq--
