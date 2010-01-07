From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next v3 2/3] can: mscan-mpc5xxx: add support for
	the MPC512x processor
Date: Thu, 7 Jan 2010 17:21:13 +0100
Message-ID: <20100107162113.GB7394@pengutronix.de>
References: <1262873421-6863-1-git-send-email-wg@grandegger.com>
	<1262873421-6863-2-git-send-email-wg@grandegger.com>
	<1262873421-6863-3-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1978503188=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262873421-6863-3-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============1978503188==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UHN/qo2QbUvPLonB"
Content-Disposition: inline


--UHN/qo2QbUvPLonB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 07, 2010 at 03:10:20PM +0100, Wolfgang Grandegger wrote:
> From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
>=20
> The main differences compared to the MSCAN on the MPC5200 are:
>=20
> - More flexibility in choosing the CAN source clock and frequency:
>=20
>   Three different clock sources can be selected: "ip", "ref" or "sys".
>   For the latter two, a clock divider can be defined as well. If the
>   clock source is not specified by the device tree, we first try to
>   find an optimal CAN source clock based on the system clock. If that
>   is not possible, the reference clock will be used.
>=20
> - The behavior of bus-off recovery is configurable:
>=20
>   To comply with the usual handling of Socket-CAN bus-off recovery,
>   "recovery on request" is selected (instead of automatic recovery).
>=20
> Note that only MPC5121 Rev. 2 and later is supported.
>=20
> Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>

Reviewed-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

It still works with our board and I didn't find anything else to comment on.

Thanks, Wolfgang!

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--UHN/qo2QbUvPLonB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktGCfkACgkQD27XaX1/VRvi2wCeM7HN2IBscYMOag2R4a9yJ7kP
lq4An0z/WN5ENEN/YU01eFA34W2GxMLh
=ECwy
-----END PGP SIGNATURE-----

--UHN/qo2QbUvPLonB--

--===============1978503188==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1978503188==--
