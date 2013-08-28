From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH] net: mdio-sun4i: Convert to devm_* api
Date: Wed, 28 Aug 2013 11:35:08 +0200
Message-ID: <20130828093508.GQ2695@lukather>
References: <1377522717-5784-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ngPZezdD7QsvFaqQ"
Cc: davem@davemloft.net, emilio@elopez.com.ar, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377522717-5784-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ngPZezdD7QsvFaqQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jisheng,

On Mon, Aug 26, 2013 at 09:11:57PM +0800, Jisheng Zhang wrote:
> Use devm_ioremap_resource instead of of_iomap() and devm_kzalloc()
> instead of kmalloc() to make cleanup paths simpler. This patch also
> fixes the resource leak caused by missing corresponding iounamp()
> of the of_iomap().
>=20
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

It looks fine for me.
Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--ngPZezdD7QsvFaqQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSHcRMAAoJEBx+YmzsjxAglCwP/iLNWRnQoo50fMuCpRKnglrc
XO4K9cPMny+RwMmyPYaixk3BB/4B7LUwbP8UgBhxVEumOsjSFh8NnA+BgnFGIs9H
/ffxkFjEyWWhcFDe+16BRuBCeFUNFaNwUe0As3xOeb0+2tMbQTPR422/yECltpUl
n0R/7F290qFlSrXMFVHp0IIZxm4NB1OofwfYi0/RZ2FQce4hjTFxVdFh79N7kHh9
qDGbyWsoqUbERui/OnMN8jlULUB/tbBUFREu/ekzB33SDTQsJGmNYuPJ35PxBmrz
whCkt9J+5S9gLVU0KoMTUM6JpxPB5MmLqJEQTQMBqxzYRHmpDs/yX94TGuid7IkK
iKa0M/YqfFCfBz+hZH7UmMbo5AoCgd2mhDAXQtw1GunNwbwZjHMgVzGD6hrUlKg5
vDMxBXj81zaqEyfF+/yIG9g3RCoWpL6L3ZtK+lMPWbGtJNqx8w8rySdcQthwE94n
3jyKN7hUlcUn/8qyqys4KVkdqLVaIQTxD1qyCEwKgnsUJ4fgbbLPB5oM/S2Ys444
n/U/b1wqOY9myLK7ludKgge5PsKdwUSo8Vg9VcI+YuAimW9sUbmwpaNznYc3jH0e
YHNWeB6LNfrRrqrPvzSa7wP9V6VX/sdR5IJd9vHoj0+kvahoBZwqF7178OVEDpRK
fp6qz66o1p8ONS6KHckm
=GtXm
-----END PGP SIGNATURE-----

--ngPZezdD7QsvFaqQ--
