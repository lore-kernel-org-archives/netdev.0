From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/7] can: m_can: fix possible sleep in napi poll
Date: Mon, 03 Nov 2014 17:24:15 +0100
Message-ID: <5457AC2F.3010200@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xB4b7BJ2xNMiOR64e8EvUKfL01CUx3hT7"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xB4b7BJ2xNMiOR64e8EvUKfL01CUx3hT7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> The m_can_get_berr_counter function can sleep and it may be called in n=
api poll function.
> Rework it to fix the following warning.

Applied to can/master.

Thanks, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xB4b7BJ2xNMiOR64e8EvUKfL01CUx3hT7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV6wvAAoJECte4hHFiupUjBAP+gNVbqTsfiuPg6gNQpEa/oXZ
BYkcego1XvAy2guM/Jetj4KrOMl1cW6Ce4FntsPcpwlkBVC8VjpE4QEp829E2FHa
laSojSXbCrbtxKdnyxBWjrbiFjiah6whpGOQDlUcyLUVoLz1U/7h4+ebmnfQBKjX
z1K2aUKDq4cC2Wq5YaFRLeD5GFC+hmE3fAWWx/dwJNLqinuYaxBUWOT2+cr3zL+p
Ok36p27XyXaEetAM+TMGpZH3pdzLB/SWdlqQCe6iQloZzlZyLNPyLL9sYff5Y4yv
LuLBy5UE4b4Sm10da1BDKPXN19FkTKFj9/z6NO5yBf0ejfXa9KHgNISOj8cqQMcS
3EJ2+nFMdPg7mivNWvL7sRRB+Udr/IBJrgSdfeIxwjBmAJAdQNoFl8A275aa5Y1o
0CIJALBu3hZWjCOf/HWTiS+v2z5xDRCj0WBNyeSqC5x2MR6b2XTsw+paNrjzgcYQ
i0zjrbPTvcEr68Ym1pGtvjnEovyCGcZGfOAM8uTmpS108tlBBkOK0+f8JOhcFzbU
LCQfC4wGp6bXcTzbAdWZOE+sJbSv8GN2i2HGDBDXR7kNgi90q2HkRzXC9GZMm2GK
AfOymQUX4QmWZxLJBv2kl+VKLRlofLkzdSXpEplh7v3nG3rOU2J5UPyHwIHqIIq8
7QJHHXusL67EGsGCskS7
=5zyt
-----END PGP SIGNATURE-----

--xB4b7BJ2xNMiOR64e8EvUKfL01CUx3hT7--
