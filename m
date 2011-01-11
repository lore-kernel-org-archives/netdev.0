From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 3/3] can: at91_can: make can_id of mailbox 0 configurable
Date: Tue, 11 Jan 2011 12:57:39 +0100
Message-ID: <20110111115739.GA25741@pengutronix.de>
References: <1294741688-22699-1-git-send-email-mkl@pengutronix.de>
	<1294741688-22699-4-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4333712072950000325=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1294741688-22699-4-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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


--===============4333712072950000325==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 11, 2011 at 11:28:08AM +0100, Marc Kleine-Budde wrote:
> Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
> "AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailbox
> 0 may be send under certain conditions (even if disabled or in rx mode).
>=20
> The workaround in the errata suggests not to use the mailbox and load it
> with a unused identifier.
>=20
> This patch implements the second part of the workaround. A sysfs entry
> "mb0_id" is introduced. While the interface is down it can be used to
> configure the can_id of mailbox 0. The default value id 0x7ff.
>=20
> In order to use an extended can_id add the CAN_EFF_FLAG (0x80000000U)
> to the can_id. Example:
>=20
> - standard id 0x7ff:
> echo 0x7ff      > /sys/class/net/can0/mb0_id
>=20
> - extended if 0x1fffffff:
> echo 0x9fffffff > /sys/class/net/can0/mb0_id

Maybe put something like this also in Documentation/ABI/testing? Perhaps
a bit more explicit: Can this interface be used? Should it be used? Must
it be used?

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk0sRbMACgkQD27XaX1/VRtXPgCeI66YI/jbQ7Wu0fHSjEKlzU8t
X8UAnAuKMh0OWf6BvU+uVns5HGs9le8M
=DCwr
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--

--===============4333712072950000325==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4333712072950000325==--
