From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Convert timers to use timer_setup()
Date: Mon, 9 Oct 2017 19:53:35 +0200
Message-ID: <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
References: <20171005005126.GA23416@beast>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="5AU76uXiNM13O7MmsqxopsQK7PMB3QfWc"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005126.GA23416@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5AU76uXiNM13O7MmsqxopsQK7PMB3QfWc
Content-Type: multipart/mixed; boundary="6Jt50wVD0tNdKCx5h5cW6BJ2GWXid2xn5";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Message-ID: <04d30a39-3e88-e46b-ad94-686da16e571e@pengutronix.de>
Subject: Re: [PATCH] net: can: Convert timers to use timer_setup()
References: <20171005005126.GA23416@beast>
In-Reply-To: <20171005005126.GA23416@beast>

--6Jt50wVD0tNdKCx5h5cW6BJ2GWXid2xn5
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 10/05/2017 02:51 AM, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointe=
r to
> all timer callbacks, switch to using the new timer_setup() and from_tim=
er()
> to pass the timer pointer explicitly.
>=20
> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-can@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.

Are you taking the patch or should I apply it?

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6Jt50wVD0tNdKCx5h5cW6BJ2GWXid2xn5--

--5AU76uXiNM13O7MmsqxopsQK7PMB3QfWc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlnbt58ACgkQHv7KIOw4
HPbZPAf+O7L5pR2SMPWXIpoAUSrzpe1DFwCAeYb0BKmg9HFVRw0ok+9ZOShFXzFD
bbinNoUx7faJGkanoIsYCwdztr+C6YkSzUOjEoLfjEUyB05KYnh2ZMFEWKRjB19c
mFtoQzKtRWcxSxQiWH/EFd7X1Y6aqRyOBsmsuQubrKSe6LWvQndBDhT4bCHk7eWy
Pww2muD85WwoLWctvG1LtcFjF+XgNH+H6Ew1aLj0LlAOpVCSfiVsJIVRZxRRZSul
2G+GF5PSlG+Qh4zvNtbzQlRyyD/3m3gQB5zDUwmsKHM2Mb6C/3ShBGT4XPU7+ErH
FcmlogTZp+KP+0DQq31n/BhwIBWd+Q==
=jJsA
-----END PGP SIGNATURE-----

--5AU76uXiNM13O7MmsqxopsQK7PMB3QfWc--
