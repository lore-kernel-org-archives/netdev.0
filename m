From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] net: flexcan: clock-frequency is optional for device
 tree probe
Date: Wed, 27 Jun 2012 10:47:24 +0200
Message-ID: <4FEAC89C.3000405@pengutronix.de>
References: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org> <1340700563-8386-2-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCC8817FDA14AD27BBB1BB06B"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50351 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab2F0Irc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:47:32 -0400
In-Reply-To: <1340700563-8386-2-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCC8817FDA14AD27BBB1BB06B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/26/2012 10:49 AM, Shawn Guo wrote:
> The property clock-frequency is optional for device tree probe.  When
> it's absent, the flexcan driver will try to get the frequency from clk
> system by calling clk_get_rate.
>=20
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

As Oliver pointed out, this doesn't go through the net tree.

Marc

> ---
>  .../devicetree/bindings/net/can/fsl-flexcan.txt    |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt =
b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> index f31b686..8ff324e 100644
> --- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> +++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> @@ -11,6 +11,9 @@ Required properties:
> =20
>  - reg : Offset and length of the register set for this device
>  - interrupts : Interrupt tuple for this device
> +
> +Optional properties:
> +
>  - clock-frequency : The oscillator frequency driving the flexcan devic=
e
> =20
>  Example:


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCC8817FDA14AD27BBB1BB06B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/qyJwACgkQjTAFq1RaXHPgsACfT6uJv3nN4L3OmhduMLcvX1f1
MjkAn3E/YwjzNZWprwuvxJVfttonozLE
=q9zW
-----END PGP SIGNATURE-----

--------------enigCC8817FDA14AD27BBB1BB06B--
