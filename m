From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v3] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 13 Oct 2010 09:38:05 +0200
Message-ID: <4CB561DD.2030304@pengutronix.de>
References: <002e01cb6486$2ed72cc0$66f8800a@maildom.okisemi.com>	<20101005.114506.184852374.davem@davemloft.net>	<000b01cb6503$962bc7f0$66f8800a@maildom.okisemi.com>	<20101005.200904.71120150.davem@davemloft.net>	<4CAC3D94.9010408@grandegger.com>
	<000c01cb69dc$5d2aaab0$66f8800a@maildom.okisemi.com>
	<4CB414A2.8020202@pengutronix.de>
	<000701cb6a8e$60de6900$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4664177505634185278=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000701cb6a8e$60de6900$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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
--===============4664177505634185278==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAB261C5061DAF079BE82C155"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAB261C5061DAF079BE82C155
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/13/2010 06:23 AM, Masayuki Ohtake wrote:
> On Tuesday, October 12, 2010 4:56 PM, Marc Kleine-Budde wrote :
>> I just had a small peak at the datasheet. It seems you can implement t=
he
>> same scheme for rx as on the at91, if you enough rx buffers. In the at=
91
>> driver I use 8+4 =3D 12 buffers for rx. Have a look at the driver, the=
 rx
>> path is documented.
>=20
> Thank you for your suggestion.
> This is valuable for us.
> It seems the at91's Hw benabior similar to ours.
> Using this method, we will implement and test.

Feel free to ask if you have questions regarding the algorithm or the
code or have some code to review.

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAB261C5061DAF079BE82C155
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAky1YeEACgkQjTAFq1RaXHP3UgCeIF/iojFe/jKvr/KdcEsOn4vV
/+IAnRjFtweclJronxQedEdt5TA3xCfS
=hSIz
-----END PGP SIGNATURE-----

--------------enigAB261C5061DAF079BE82C155--

--===============4664177505634185278==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4664177505634185278==--
