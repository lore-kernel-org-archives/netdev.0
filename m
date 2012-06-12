From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 12 Jun 2012 16:46:32 +0200
Message-ID: <4FD75648.7060702@pengutronix.de>
References: <4FC135C6.5030206@grandegger.com> <1338816766-7089-2-git-send-email-federico.vaga@gmail.com> <4FCCC077.7000303@pengutronix.de> <2105333.GQGP4hKIYU@harkonnen>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig28374E933A468630350573AD"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <2105333.GQGP4hKIYU@harkonnen>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig28374E933A468630350573AD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/12/2012 04:25 PM, Federico Vaga wrote:
>>> +out_free_clock:
>>> +	if (!priv->priv)
>>
>>            ^^^
>>
>> looks fishy
>=20
> Also c_can_platform.c use priv->priv when it needs to get clk. I can ad=
d=20
> a comment to specify what the statement do.

> +out_free_clock:
> +	if (!priv->priv)
> +		clk_put(priv->priv);

Why do you call clk_put on priv->priv, if priv->priv is NULL?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig28374E933A468630350573AD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/XVkgACgkQjTAFq1RaXHPa2QCePTAWniuYkAWURBkjbmYbR7pe
wkEAn3+b16dz+073eYLCrWilNg8AdqkD
=VOy/
-----END PGP SIGNATURE-----

--------------enig28374E933A468630350573AD--
