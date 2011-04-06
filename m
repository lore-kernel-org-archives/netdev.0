From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH/RFC] can: mcp251x: Allow pass IRQ flags through platform
	data.
Date: Wed, 06 Apr 2011 08:57:12 +0200
Message-ID: <4D9C0EC8.2060408@pengutronix.de>
References: <1302023321-25182-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5019498470168803656=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: Enric Balletbo i Serra <eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1302023321-25182-1-git-send-email-eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============5019498470168803656==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4757EF955677D62E6ED03290"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4757EF955677D62E6ED03290
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/05/2011 07:08 PM, Enric Balletbo i Serra wrote:
> When an interrupt occurs, the INT pin is driven low by the
> MCP251x controller (falling edge) but in some cases the INT
> pin can be connected to the MPU through a transistor or level
> translator which inverts this signal. In this case interrupt
> should be configured in rising edge.
>=20
> This patch adds support to pass the IRQ flags via
> mcp251x_platform_data.
>=20
> Signed-off-by: Enric Balletbo i Serra <eballetbo-VIneJrwqLopBDgjK7y7TUQ@public.gmane.org>

looks good

Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4757EF955677D62E6ED03290
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2cDssACgkQjTAFq1RaXHNK5wCdEmh42/Ih5hKUDpJ2GT9bmwiB
rgMAnRlelDnjp082IrKZyMe3C7VXC1vJ
=BTvr
-----END PGP SIGNATURE-----

--------------enig4757EF955677D62E6ED03290--

--===============5019498470168803656==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5019498470168803656==--
