From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 20:53:11 +0200
Message-ID: <4E403097.4020306@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>	<20110808144424.GY4926@sgi.com>
	<4E3FF9EA.6030601@grandegger.com> <4E3FFD5B.7080000@pengutronix.de>
	<4E4001E1.3030508@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1712257848420726622=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E4001E1.3030508-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============1712257848420726622==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6265233AAE04C87139791E67"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6265233AAE04C87139791E67
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 05:33 PM, Wolfgang Grandegger wrote:
>> ACK - The device tree bindings as in mainline's Documentation is a mes=
s.
>> If the powerpc guys are happy with a clock interfaces based approach
>> somewhere in arch/ppc, I'm more than happy to remove:
>> - fsl,flexcan-clock-source (not implemented, even in the fsl driver)
>>
>> - fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
>> - clock-frequency           /   a single clock-frequency attribute
>=20
> In the "net-next-2.6" tree there is also:
>=20
>  $ grep flexcan arch/powerpc/boots/dts/*.dts
>   p1010rdb.dts:			fsl,flexcan-clock-source =3D "platform";
>   p1010rdb.dts:			fsl,flexcan-clock-source =3D "platform";
>   p1010si.dtsi:			compatible =3D "fsl,flexcan-v1.0";
>   p1010si.dtsi:			fsl,flexcan-clock-divider =3D <2>;
>   p1010si.dtsi:			compatible =3D "fsl,flexcan-v1.0";
>   p1010si.dtsi:			fsl,flexcan-clock-divider =3D <2>;
>=20
> Especially the fsl,flexcan-clock-divider =3D <2>; might make people thi=
nk,
> that they could set something else.

ARGH... :D

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig6265233AAE04C87139791E67
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5AMPUACgkQjTAFq1RaXHP6OACfYLDH67bfElwkZtkoDjGmeDt7
LMIAmQGVk5kk6j7YBHBwxx57fB3pqH04
=YQeE
-----END PGP SIGNATURE-----

--------------enig6265233AAE04C87139791E67--

--===============1712257848420726622==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1712257848420726622==--
