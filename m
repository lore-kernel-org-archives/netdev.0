From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] net: flexcan: clock-frequency is optional for device
 tree probe
Date: Wed, 27 Jun 2012 10:59:07 +0200
Message-ID: <4FEACB5B.2040508@pengutronix.de>
References: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org> <1340700563-8386-2-git-send-email-shawn.guo@linaro.org> <4FEAC89C.3000405@pengutronix.de> <20120627085600.GB9787@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5E5FFC5A70517A0CB878174C"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39651 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201Ab2F0I7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:59:13 -0400
In-Reply-To: <20120627085600.GB9787@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5E5FFC5A70517A0CB878174C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/27/2012 10:56 AM, Shawn Guo wrote:
> On Wed, Jun 27, 2012 at 10:47:24AM +0200, Marc Kleine-Budde wrote:
>> On 06/26/2012 10:49 AM, Shawn Guo wrote:
>>> The property clock-frequency is optional for device tree probe.  When=

>>> it's absent, the flexcan driver will try to get the frequency from cl=
k
>>> system by calling clk_get_rate.
>>>
>>> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
>=20
> Thanks.
>=20
>>
>> As Oliver pointed out, this doesn't go through the net tree.
>>
> From what I have seen, device tree maintainers are generally fine with
> having binding document updates go through subsystem tree.

Okay. Then I'll take that patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig5E5FFC5A70517A0CB878174C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/qy1sACgkQjTAFq1RaXHOMcACgiTdx4xOSVAq0zZTcMEN2ycAf
jWYAnjUZePabOw+mSCFdVxSSu8UuexTM
=ylPe
-----END PGP SIGNATURE-----

--------------enig5E5FFC5A70517A0CB878174C--
