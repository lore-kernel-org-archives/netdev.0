From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 6/8] can: mcp251x: Don't use pdata->model for chip
	selection anymore
Date: Mon, 18 Oct 2010 16:14:58 +0200
Message-ID: <4CBC5662.6070302@pengutronix.de>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de>
	<1287408674-15412-7-git-send-email-mkl@pengutronix.de>
	<d4c9d3f3d2843bd9cdb4cbb6a75236ce@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8549587534106876117=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Zyngier <maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <d4c9d3f3d2843bd9cdb4cbb6a75236ce@localhost>
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
--===============8549587534106876117==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig713F727A142CB054E1F76608"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig713F727A142CB054E1F76608
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/18/2010 03:49 PM, Marc Zyngier wrote:
>=20
> On Mon, 18 Oct 2010 15:31:12 +0200, Marc Kleine-Budde <mkl@pengutronix.=
de>
> wrote:
>> Since commit e446630c960946b5c1762e4eadb618becef599e7, i.e. v2.6.35-rc=
1,
>> the mcp251x chip model can be selected via the modalias member in the
>> struct spi_board_info. The driver stores the actual model in the
>> struct mcp251x_platform_data.
>>
>> From the driver point of view the platform_data should be read only.
>> Since all in-tree users of the mcp251x have already been converted to
>> the modalias method, this patch moves the "model" member from the
>> struct mcp251x_platform_data to the driver's private data structure.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>> Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
>> Cc: Marc Zyngier <maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>
>=20
> Acked-by: Marc Zyngier <maz-20xNzvSXLT6hUMvJH42dtQ@public.gmane.org>

Thanks, but I was to slow to push your Ack, David has pulled already.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig713F727A142CB054E1F76608
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAky8VmcACgkQjTAFq1RaXHOE8QCggqf3f4LULenDWAcTnYNfHMnD
1CAAoIUJaM/AhNhXfrSAUMSY4xCSWJcJ
=SJUV
-----END PGP SIGNATURE-----

--------------enig713F727A142CB054E1F76608--

--===============8549587534106876117==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8549587534106876117==--
