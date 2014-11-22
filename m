From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: eliminate banner[] variable and switch to pr_info()
Date: Sat, 22 Nov 2014 17:59:07 +0100
Message-ID: <5470C0DB.9080900@pengutronix.de>
References: <1416642155-31816-1-git-send-email-jmmahler@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7KSnNMPQbH53b4pehpLxxXQNhAn3S8823"
Cc: "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeremiah Mahler <jmmahler@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416642155-31816-1-git-send-email-jmmahler@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7KSnNMPQbH53b4pehpLxxXQNhAn3S8823
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/22/2014 08:42 AM, Jeremiah Mahler wrote:
> Several CAN modules use a design pattern with a banner[] variable at th=
e
> top which defines a string that is used once during init to print the
> banner.  The string is also embedded with KERN_INFO which makes it
> printk() specific.
>=20
> Improve the code by eliminating the banner[] variable and moving the
> string to where it is printed.  Then switch from printk(KERN_INFO to
> pr_info() for the lines that were changed.

Applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7KSnNMPQbH53b4pehpLxxXQNhAn3S8823
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUcMDeAAoJECte4hHFiupUbiIP/j/eSss/WXIZf/EaxW6cui8D
un16nudHbCmfuVAjSkMF7Be/wwtsSy0W2KTSOGI+PfgzYeInEsT+rfdMMeGEpIom
bQNsG9J8Uv6vf32KQAC4G+h1GRL8YdTeDIWceFNNKFbtYBKp4xa5m94bVkgWeK5s
B4OsaLV1eQOiw+gRqjWWe0BHsFhVQc0ifndLhTgkEcDh8Bsq58AAX9mWul0THAs3
YJY1hbVu/lUTKkwahmvUS/5QcP0MjB9hUS/xBiCga4FNHvpu/XESZ97EjjZ10Xth
BezRXcGNZCNZPzN/94aEGdQeZKg80vrfafjO8G9OHbFmozqR+TMT0RCwHq8+kTBa
iDW9p+BUUyHeCcK9G6Q/m1F8MnSA2oGL0YZu6BzEAAWnXHaM9TPM9yi9zS/CzXAu
c38Y//UyWM68ShUOE7Qlgpjxbm5Spgvsvir25lnVn9SspdD/iZ8kLgYt9Id214tU
ewhfuaaFJNB+t0dc0/g+7BxA8p6RwwHQwFiOEVSgxMgfd4sGGOvjiqnJz77/Hm79
ixJO3YMJ6LmOVOTX1ydRzSJHaVlA26VreTZ/gBgvOJFwm6qGUIuT5iYVz5wLkgkz
ke5QwkzbmOmnxGR+wSrHctWeWCMDTObCUbGil7c3KnPmS90CdGKvUxisdpxLdiRd
z+MqaSKGKFVLE/qxxaUT
=7+dH
-----END PGP SIGNATURE-----

--7KSnNMPQbH53b4pehpLxxXQNhAn3S8823--
