From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v7 ethtool 2/2] ethtool: Support for configurable RSS
 hash key
Date: Sun, 21 Sep 2014 21:52:31 +0100
Message-ID: <1411332751.20019.24.camel@decadent.org.uk>
References: <1406031667-30364-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <7ea09e91-8845-4e2a-b69a-3796b0825664@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rnm/y7IJf8b9qEpcAtfY"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33079 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751311AbaIUUwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 16:52:45 -0400
In-Reply-To: <7ea09e91-8845-4e2a-b69a-3796b0825664@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rnm/y7IJf8b9qEpcAtfY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-07-22 at 17:51 +0530, Venkat Duvvuru wrote:
> This ethtool patch will primarily implement the parser for the options pr=
ovided
> by the user for get and set rxfh before invoking the ioctl.
> This patch also has
> 1. Ethtool man page changes which describes the Usage of
>    get and set rxfh options.
> 2. Test cases for get and set rxfh in test-cmdline.c
>=20
> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
[...]

FAIL: test-cmdline
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

E: ethtool --rxfh devname hkey foo returns 0
E: ethtool -X devname hkey foo returns 0

The problem with these test cases is we can't parse the hash key (and
reject "foo") until after we start sending ioctls.  test-cmdline doesn't
include any mocking of ioctls, but instead makes each test successful if
it calls an ioctl.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camu=
s

--=-rnm/y7IJf8b9qEpcAtfY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVB86lOe/yOyVhhEJAQrtxhAAkUgIwPyGoUKcBfsZioS4latZOx+YZB7i
y0z1X6U84cN9ggOkTXJVyGMceUE2QSDIB8kKAIGWvzBmI6TFHNAAdZoQ+KnaMlKC
N9n1YakWs87xuEOR/M6ueXA//Sue/8lwWPArDrSL0yI/kPDH/3k5x181XkyIGWAA
NVzrJoHgbDCbSw///G9NbxxaPk39cuOVNfpgYs5t4Azm77ItJOWrnaCNih+1u4Ra
4I00eaeCkblnRpUwXYQB54DHzXil1fgwCmeIWBjmrxl11kTdaHJJN0gmsmZwsoxG
MDIc0gyIpRt0PTI1Stknnf3vIjF337l9zpBMoGyFL0FVA6GvzAeelUcB/BV08ejz
kVydopxtOCZWuZVeChNEepx7V3ruRJaZghImQqm0Jsm1TmksYvkI8nJrZHOQMxIH
whQrJLKyYdgCkZpJP5rJhPioESnymzrLLDRIKJ3GSgqUdO01L+SFjoRT6oFzKKT3
Y6PHsSRR9yQMwAutyQrfrmUdfSVFfDdT3L/iIMFs+vRxNVkna5P2zX5vomoFqGrl
ZlZquQsZcjww1DwJn2kD5s6Eiqi/AMyRgTcWVZ9fdkMNgdxr2zdgbP/cRN+nMt58
iI65HytnSp6nZ4c3kd4aZ1AJ4extJ5SjF5TAYwre2IsRLI3mwGA8fHG9E3oc4HET
GsmQzn2bd8U=
=qkh7
-----END PGP SIGNATURE-----

--=-rnm/y7IJf8b9qEpcAtfY--
