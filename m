From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH V4] CAN: Add Flexcan CAN controller driver
Date: Wed, 21 Jul 2010 23:42:44 +0200
Message-ID: <4C4769D4.6000601@pengutronix.de>
References: <1279746286-19736-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6765209502036268576=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1279746286-19736-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
--===============6765209502036268576==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA0C1E65A808A86AC8D066BBB"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA0C1E65A808A86AC8D066BBB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

Marc Kleine-Budde wrote:
> This core is found on some Freescale SoCs and also some Coldfire
> SoCs. Support for Coldfire is missing though at the moment as
> they have an older revision of the core which does not have RX FIFO
> support.
>=20
> Signed-off-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>=20
> Changes to prev version:
>=20
> * use be32_to_cpup in flexcan_start_xmit
> * add comments about stats->tx_bytes and stats->tx_bytes
> * fix FLEXCAN_ESR_ACK_ERR (set CAN_ERR_BUSERROR)
> * add forgotten FLEXCAN_ESR_CRC_ERR
> * fix inc of can.can_stats.error_warning
> * handle changes of CAN error state in NAPI
> * only send bus error in case of a real error
> * implement CAN_CTRLMODE_BERR_REPORTING
>=20
> The CAN_CTRLMODE_BERR_REPORTING implementation is a bit tricky, we have=
 to
> enable the error bit interrupt, otherwise we don't get any warning or
> error passive interrupts. Regarding error bits NAPI is only scheduled i=
f
> CAN_CTRLMODE_BERR_REPORTING is activated. The NAPI-poll() is analogue, =
only
> generate bus error messages of CAN_CTRLMODE_BERR_REPORTING is active.
>=20
> Cheers, Marc
>=20
> P.S.: this can be pulled, too:
>=20
> The following changes since commit 11fe883936980fe242869d671092a466cf1d=
b3e3:
>=20
>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
davem/net-2.6 (2010-07-20 18:25:24 -0700)
>=20
> are available in the git repository at:
>=20
>   ssh://git.pengutronix.de/git/mkl/linux-2.6.git for-net-next-2.6

The correct URL is:

	git://git.pengutronix.de/git/mkl/linux-2.6.git for-net-next-2.6
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA0C1E65A808A86AC8D066BBB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxHadkACgkQjTAFq1RaXHNypwCeLMGCX0auKoGsFy5NXpSwpMd1
YtAAniTQCUfxC3Y7oTDLczRYgovHJzY8
=Z9zM
-----END PGP SIGNATURE-----

--------------enigA0C1E65A808A86AC8D066BBB--

--===============6765209502036268576==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6765209502036268576==--
