From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH linux-firmware] bnx2x: adding fw 7.2.51
Date: Fri, 20 Apr 2012 02:01:59 +0100
Message-ID: <1334883719.3209.233.camel@deadeye>
References: <1334831600.23463.9.camel@lb-tlvb-barak.il.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yrJXrIUNqX0eTiNUd/GW"
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: barak@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52556 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751257Ab2DTBCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 21:02:03 -0400
In-Reply-To: <1334831600.23463.9.camel@lb-tlvb-barak.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yrJXrIUNqX0eTiNUd/GW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-04-19 at 13:33 +0300, Barak Witkowski wrote:
> This new FW adds support in AFEX mode (multifunction using vntag
> header).
> It also fixes following issues:
> 1. Theoretical bug in GRO acceleration (only if the GRO Segment Length
>    is a multiple of the SGE Size). This will allow removing the
>    workaround from the driver.
> 2. When a TPA aggregation is open and a packet is accepted with
>    timestamp OOO, the new packet begins a new aggregation instead of
>    being indicated separately.
>=20
> Signed-off-by: Barak Witkowski <barak@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  WHENCE                      |    3 +++
>  bnx2x/bnx2x-e1-7.2.51.0.fw  |  Bin 0 -> 162152 bytes
>  bnx2x/bnx2x-e1h-7.2.51.0.fw |  Bin 0 -> 169960 bytes
>  bnx2x/bnx2x-e2-7.2.51.0.fw  |  Bin 0 -> 295264 bytes
>  4 files changed, 3 insertions(+), 0 deletions(-)
>  create mode 100644 bnx2x/bnx2x-e1-7.2.51.0.fw
>  create mode 100644 bnx2x/bnx2x-e1h-7.2.51.0.fw
>  create mode 100644 bnx2x/bnx2x-e2-7.2.51.0.fw
[...]

Applied, thanks.

Please note that my work on the linux-firmware repository is not related
to my job, so the correct address to use is ben@decadent.org.uk.

Ben.

--=20
Ben Hutchings
This sentence contradicts itself - no actually it doesn't.

--=-yrJXrIUNqX0eTiNUd/GW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT5C1h+e/yOyVhhEJAQpjLw//dlu1ZJ5ZTZ7R7H/DInW2BUpWDDUhPVHf
GBadISBsTQPiHyIIsqtK0n6GihzOMpY7lH/++vHz1mVqHGW8El9a0uz/Kv5wQGfs
obc5g5A+3qCrj+qVunYxJK1ng/CBO3X3fZ3qSbKguEFQiB/2eGXKxxagWHqrpeYv
ZEKRap5XYZQLu/vdszVSshN75QdQXioD+Th4ZXin1E7CzRWJmTAFzd2t/g+SEry0
3jTbUrp0DEdxKSE+4Ap3Usm4uZ/0/fCEKrGhGpt/PVajJ/GyfKJRm0VrZco/NTiY
QwyqKALhgSE7BuAgALhfCnDAEcHeg3eWx9frTvGtbXRe2ugRyCIckalX9neCjgeE
YpefuY4v/vYHDKtlMNQb06JTwCRCDFTBjb7bv2vdCioWt6w6ObvFCUw7BcLSCUAm
XmBOK7HkMHP7m2wHdBVd/hGTwVACiBUp5tyc09N2hzJSi21bVTtulL7pvoghaLoo
LqgWPaHavZiSdFWSDwEgKcfpUGjVnnEV3WO7Ahms+6lFdUjH+1oMokqK/irfrRiK
ekDST1hOJtFUT5FLhGCJlq/hQYxANT4pEt5f7pSdPXqo5JOZA059K3iPiEwl2Cn2
3/qfTFV9nbDcIubBPWp7aH05nrXWfZohJQ8uG5e1e9LjOfxeS+3fJW1LQn7vE5yN
P5jwiBBWG6o=
=GyYe
-----END PGP SIGNATURE-----

--=-yrJXrIUNqX0eTiNUd/GW--
