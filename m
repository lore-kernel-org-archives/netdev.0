From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 11:04:37 +0200
Message-ID: <20170908090437.GE16834@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="BQPnanjtCNWHyqYD"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BQPnanjtCNWHyqYD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-09-07 21:11:45, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Add other KSZ switches support so that patch check does not complain.

Nice; unlike Andrew I believe that adding compatible strings is ok
before the support is added. Device tree description is
Linux-independend.

But... you need to Cc: device tree maintainers on this one. They
usually take some time to respond, so it is nice to do this early.

> index 0ab8b39..34af0e0 100644
> --- a/Documentation/devicetree/bindings/net/dsa/ksz.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> @@ -3,8 +3,15 @@ Microchip KSZ Series Ethernet switches
> =20
>  Required properties:
> =20
> -- compatible: For external switch chips, compatible string must be exact=
ly one
> -  of: "microchip,ksz9477"
> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
> +	      "microchip,ksz8795" for KSZ8795 chip,
> +	      "microchip,ksz8794" for KSZ8794 chip,
> +	      "microchip,ksz8765" for KSZ8765 chip,
> +	      "microchip,ksz8895" for KSZ8895 chip,
> +	      "microchip,ksz8864" for KSZ8864 chip,
> +	      "microchip,ksz8873" for KSZ8873 chip,
> +	      "microchip,ksz8863" for KSZ8863 chip,
> +	      "microchip,ksz8463" for KSZ8463 chip
> =20
>  See Documentation/devicetree/bindings/dsa/dsa.txt for a list of addition=
al  required and optional properties.

And you may want to wrap long line here, unless that's email client
playing another trick.
								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--BQPnanjtCNWHyqYD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyXSUACgkQMOfwapXb+vIwZwCdHMGajwWwF6rSVtXeiqJ48Jt5
M50An19C+hx4bJm1EspoC+xYN0rQDCus
=YmLd
-----END PGP SIGNATURE-----

--BQPnanjtCNWHyqYD--
