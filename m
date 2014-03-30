From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.13.y] nfqueue: Orphan frags in nfqnl_zcopy and handle
 errors
Date: Mon, 31 Mar 2014 00:56:42 +0100
Message-ID: <1396223802.1241.33.camel@deadeye.wl.decadent.org.uk>
References: <20140328142914.GB25962@hansolo.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/7YSqv1imvPG/k/NLRfH"
Cc: "David S. Miller" <davem@davemloft.net>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37445 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbaC3X4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 19:56:54 -0400
In-Reply-To: <20140328142914.GB25962@hansolo.jdub.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/7YSqv1imvPG/k/NLRfH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-28 at 10:29 -0400, Josh Boyer wrote:
> Backport of upstream commit 36d5fe6a0007 to 3.13.y
>=20
> nfqnl_zcopy can copy elements of the frags array between skbs, but it doe=
sn't
> orphan them.  Also, it doesn't handle errors, so this patch takes care of=
 that
> as well, and modify the caller accordingly.  skb_tx_error() is also added=
 to
> the callers so they will signal the failed delivery towards the creator o=
f the
> skb.
>=20
> Fixes CVE-2014-2568.
>=20
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>
[...]

FWIW, I applied the same change to Debian's 3.13.7-1, except for leaving
'from' as pointer-to-const.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-/7YSqv1imvPG/k/NLRfH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzivOue/yOyVhhEJAQr4fw//YTLtiI2yhodiHs+aYyVEm/3eRQt5+VP+
eKMK7acXdZTBnMoqBbgtrvH3LVKw0iFf2wvLAP5InwFV3w4RCngcTZeqWVomsLyH
Ilq44q/AjK6YseeA+py3ZvPPZ0ZQCNFryPf4ifqzoAgp9qdBRe6HDH0akq8uOqlh
x2pdJGCJmfdkCsgNgFyG4MdaLumFvsWvi9+wAV1nBSPSfLoa0UTq3hPJQambcEt7
YpPBycfp2z8CM51UA/KUv3ORtbaWyDDVSXLWc2iCqA2Sm77GFrZNACWgA0RCzcTx
jk20rdJ6Xfh9Q2XKehNX9J8lAI5M94Ga39CKpfsjxjVazlrrJf51BCpvKBDW4xhZ
HJr6x58UAvar5nDdwMChunn94IAnvsJJJOWnInsXPeXkesBkfTtv7QjSlGO2HdIt
xEnTrR3wGmsqYJdmXTt7hCo34oGJ+z4Vzv2rgZuvkRdDiFVYn8R202zwTzLUNAlu
5H+CDu0LWOJIM5D0T/nfOUnhqlNX50IzNeEGXDuROm4Z5wFS8xIHLHvYNoLXn8P9
XGaCn3VvVQxaJ1FTvpE0Q0B8ly7A3OdtL1I0EHpDJGxy2VVBQ8mvHPt30UluWIv1
QVW5lkJzFip0n0haIQlfaw4b5dlFeDwOHoFO+5NTZ/MZTcbSgr22kX6uUDhRh3tA
OcT1lYo6rSA=
=8ICj
-----END PGP SIGNATURE-----

--=-/7YSqv1imvPG/k/NLRfH--
