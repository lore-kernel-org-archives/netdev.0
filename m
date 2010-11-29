From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next-2.6 01/19 v5] can: EG20T PCH: Separate Interface
 Register(IF1/IF2)
Date: Mon, 29 Nov 2010 10:22:27 +0100
Message-ID: <4CF370D3.7020606@pengutronix.de>
References: <4CEF150A.7080409@dsn.okisemi.com>	<4CEF84BE.7000101@pengutronix.de> <4CEF864B.6080207@pengutronix.de> <002201cb8f69$11d30050$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6599FCA0CD6EF44EAC1F0816"
Cc: andrew.chih.howe.khor@intel.com,
	Samuel Ortiz <sameo@linux.intel.com>, margie.foster@intel.com,
	netdev@vger.kernel.org, Christian Pellegrin <chripell@fsfe.org>,
	linux-kernel@vger.kernel.org, yong.y.wang@intel.com,
	socketcan-core@lists.berlios.de, kok.howg.ewe@intel.com,
	joel.clark@intel.com, "David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>, qi.wang@intel.com
To: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60922 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab0K2JWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 04:22:49 -0500
In-Reply-To: <002201cb8f69$11d30050$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6599FCA0CD6EF44EAC1F0816
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/29/2010 02:59 AM, Tomoya MORINAGA wrote:
> On Friday, November 26, 2010 7:04 PM, Marc Kleine-Budde wrote:
>=20
>>> nitpick: it's unusual to have leading whitespace in the patch descrip=
tion.
>=20
>> maybe it's a problem of your mailer.
> I can see the whitespace created patch by "git format-patch"
> I show the head of patch below.
>=20
> From e53c63a8ff00c76f165e371511604f374451627b Mon Sep 17 00:00:00 2001
> From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
> Date: Thu, 18 Nov 2010 09:18:15 +0900
> Subject: [PATCH] CAN : Separate interface register from whole of regist=
er structure.
>  CAN register of Intel PCH EG20T has 2 sets of interface register.
>  To reduce whole of code size, separate interface register.
>  As a result, the number of function also can be reduced.
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>

Maybe your patch description in git commit is unusual. It should be a
one line patch subject, followed by a blank line, then a multi line
patch description. The a blank line followed by the S-o-b. Have a look
at 15) in Documentation/SubmittingPatches.

> ---
>  drivers/net/can/pch_can.c |  445 ++++++++++++++++++++-----------------=
--------
>  1 files changed, 201 insertions(+), 244 deletions(-)
>=20
> .........
>=20
> Since I have copied from the patch file directly, whitespace is inserte=
d.
> When next resubmitting, I will delete the whiletespace by hand.

No need for this.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6599FCA0CD6EF44EAC1F0816
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzzcNgACgkQjTAFq1RaXHMALgCffBq3x3mvrjP1NWN0qClh4RAm
p60Ani+K0uPxVuA6Ml8RhMg9mSV6pItv
=R3O9
-----END PGP SIGNATURE-----

--------------enig6599FCA0CD6EF44EAC1F0816--
