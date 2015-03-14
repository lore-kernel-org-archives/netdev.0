From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 3/3] can: kvaser_usb: Use can-dev
 unregistration mechanism
Date: Sat, 14 Mar 2015 16:26:56 +0100
Message-ID: <55045340.6050908@pengutronix.de>
References: <20150226152011.GA6075@linux> <20150314130249.GA20796@linux> <20150314130952.GB20796@linux> <20150314131147.GC20796@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="heV5HrSpjSfqSXj5BiNEnVJvEg4GJ9Xfd"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150314131147.GC20796@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--heV5HrSpjSfqSXj5BiNEnVJvEg4GJ9Xfd
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/14/2015 02:11 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> Use can-dev's unregister_candev() instead of directly calling
> networking unregister_netdev(). While both are functionally
> equivalent, unregister_candev() might do extra stuff in the
> future than just calling networking layer unregistration code.

Since 2 goes into can, I've applied this into can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--heV5HrSpjSfqSXj5BiNEnVJvEg4GJ9Xfd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVBFNEAAoJECte4hHFiupUC8oP/3uY22Gfujd+UiuZzVazaBFG
kv91SnSHc2DxOY86aG5GNaZK6VChzFY0DlHz6GK1QbX4kho4+uUKUjb2szHIACPS
Wl2v7mfeRZpxUl69IBfv05/FUIwiUNJxLYRZNyJBf0KLkHAtngVoAqnYKc0FCJHU
Q/bew1GLUJpk2PRw7Kg0v+euELb3MPW+XL+CaWo2piak3MWoJ80jiQoWijJzRhV0
SKs5Xj0VtSOKGeAI6xVHGxkWdvhIoIf08DryjMabvZL5nDgnQzlUzACQQzCW4KWF
C4VY1yj4AtJomvgj3An7Zt0RNDJ3D1mLFsOZcvdXbB5wyPAp6cvcNsoww+YI36xt
Ap7xuwPyhQOzzt9xsHeaUy8FbEig6Zyli+E3lxZ1t2nruMVWMQfX1JHwvR+rZjEK
g0M2zoRkNP52ZNcWN7HGgumPM7mMZelJ86la5cQIEaOhwVQOjtSSHaLileh1XSjM
5xSpQYkfGWaFIAel9rEg3iynHOq5usjigxTAI7wp5gvkkmJtMtt4ViTdMb0VESn9
fEiVHk1/R3KYZkE5DrNBCBnTmJyjYpjhyrgJW3u0YmatE+50O2Z/ebSk+9TRjxAf
BXpFHQ2ZvqBc0Zrj+UhPUlXYIZZLxa0YW/aBmQ/oQ+kBkj4lIsBZ6Ww/cXKBdo0X
A7krWL+BwhWcZRqWPdVD
=h0ks
-----END PGP SIGNATURE-----

--heV5HrSpjSfqSXj5BiNEnVJvEg4GJ9Xfd--
