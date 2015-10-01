From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: Allow installing custom reg_update_bits
 function
Date: Thu, 1 Oct 2015 10:44:24 +0100
Message-ID: <20151001094424.GG15635@sirena.org.uk>
References: <1443681187-29505-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gnQ/OOKD4CRsnGw/"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443681187-29505-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gnQ/OOKD4CRsnGw/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 01, 2015 at 02:33:06AM -0400, jon@ringle.org wrote:

> @@ -2509,6 +2510,10 @@ static int _regmap_update_bits(struct regmap *map,=
 unsigned int reg,
>  	int ret;
>  	unsigned int tmp, orig;
> =20
> +	if (map->reg_update_bits)
> +		return map->reg_update_bits(map->bus_context, reg, mask, val,
> +					    change, force_write);
> +
>  	ret =3D _regmap_read(map, reg, &orig);
>  	if (ret !=3D 0)
>  		return ret;

This completely bypasses and therefore breaks the cache infrastructure.

--gnQ/OOKD4CRsnGw/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWDQB0AAoJECTWi3JdVIfQ56EH/jsIherTbXeVdgBLzRyDh6M7
XZSYBtyEaijtayi9HUggojZvo1JaRdocHZBaxLYKayd+puMCzJJ4vpIjOgNsN27t
3xPchNaa6Q8fVh3cqW38aFXwQ/D8eypw6nIxcM53MdB6rZPNKXfeUGAqC7qc3Cc+
FoCJOzcpoApj5OkBF2LV/RVcIMvTFPdATMXUGc8efeavYTLceGh016tFjl0egnOw
fRMSl7lUqWjMbtarnikqkveTbUK0uojSrObV6EB0aEgaPdS6CZXsTr+EICHKFEDj
A/Hg3uluEICQ+LYidcnO2HIC/8doeqKjz7Q6FM5jDS83xynMiPZXWy4F48+uflI=
=Q3Hs
-----END PGP SIGNATURE-----

--gnQ/OOKD4CRsnGw/--
