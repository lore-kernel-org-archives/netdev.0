From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: only call can_stat_update with procfs
Date: Wed, 22 Jun 2016 22:36:52 +0200
Message-ID: <04d27ce4-9393-764e-7e73-b1854a0136c3@pengutronix.de>
References: <20160620155234.2414971-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="UgMgiITliweJhsGRCMLxXbIDKNjcpnH8O"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Aring <aar@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160620155234.2414971-1-arnd@arndb.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UgMgiITliweJhsGRCMLxXbIDKNjcpnH8O
Content-Type: multipart/mixed; boundary="a4PcgO8XHucxOnLh8QMTKlFCSSGR2NMGa"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>, Alexander Aring
 <aar@pengutronix.de>, linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <04d27ce4-9393-764e-7e73-b1854a0136c3@pengutronix.de>
Subject: Re: [PATCH] can: only call can_stat_update with procfs
References: <20160620155234.2414971-1-arnd@arndb.de>
In-Reply-To: <20160620155234.2414971-1-arnd@arndb.de>

--a4PcgO8XHucxOnLh8QMTKlFCSSGR2NMGa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/20/2016 05:51 PM, Arnd Bergmann wrote:
> The change to leave out procfs support in CAN when CONFIG_PROC_FS
> is not set was incomplete and leads to a build error:
>=20
> net/built-in.o: In function `can_init':
> :(.init.text+0x9858): undefined reference to `can_stat_update'
> ERROR: "can_stat_update" [net/can/can.ko] undefined!
>=20
> This tries a better approach, encapsulating all of the calls
> within IS_ENABLED(), so we also leave out the timer function
> from the object file.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: a20fadf85312 ("can: build proc support only if CONFIG_PROC_FS is=
 activated")

Applied to can-next.

Tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--a4PcgO8XHucxOnLh8QMTKlFCSSGR2NMGa--

--UgMgiITliweJhsGRCMLxXbIDKNjcpnH8O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXavbkAAoJED07qiWsqSVq1RYIAJeZDzEUBQAV9dvppUNQim2R
ZpX+gz41W7Zbul2QmVS4veflrWRbAs10rDX7+4x589ay3A46hVY4y1gpnxSofzXC
0AIbsa0N+k4Hi63UDBPMjnqvfEUW/+RFmzflKF5cf65/JVmANCxRev0rcsIjZ3pH
5FlT+LZXuH6AifQFhDeE29OjUM/0qNCyEO9IHgZjms2YK7DIF5Nh29uuA44lw6zg
o3TVZDLJWarH+z7v1fblxEOu6Q6iwK5HOFjBCmY7glMuVhKCUCcAAyZ/2HlxmGQq
EliER2w1WDHw1r4oZcOQ/y6MkMA+w9CZkT8qMI9f8wZLUJJYRxyhDH8fMY3/cww=
=QeYK
-----END PGP SIGNATURE-----

--UgMgiITliweJhsGRCMLxXbIDKNjcpnH8O--
