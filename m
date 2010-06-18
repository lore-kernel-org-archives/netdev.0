From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 12:16:54 +0200
Message-ID: <4C1B4796.3060506@pengutronix.de>
References: <20100617105201.GA2015@bluebox.local>
	<4C1B4098.3090800@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4768573705801923171=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C1B4098.3090800-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============4768573705801923171==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD3416911BA5FADBA91EBA899"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD3416911BA5FADBA91EBA899
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> Hi Hans-J=FCrgen,
>=20
> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>> This adds a driver for FlexCAN based CAN controllers,
>> e.g. found in Freescale i.MX35 SoCs.
>>
>> The original version of this driver was posted by Sascha Hauer in July=
 2009:
>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>
>> I took this version, added NAPI support, and fixed some problems found=

>> during testing. Well, here is the result. Please review.
>=20
> I briefly browsed the patch and various bits and pieces are missing or
> not correctly implemented. Marc already pointed out a few of them:
>=20
> - I do not find can_put/get_echo_skb functions in the code. How is
>   IFF_ECHO supposed to work?

the driver uses hardware loopback

> - Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()
>   seems to be missing.
>=20
> - Make use of alloc_can_skb() and alloc_can_err_skb().

the last two points are already addressed in my version of the driver.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD3416911BA5FADBA91EBA899
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkwbR58ACgkQjTAFq1RaXHOQRACeLnMJB3VKqTCx3gB/F6tfgJ7t
SBQAniMEaz+Am9xWwBfHwJyMCbdheRUV
=+r3r
-----END PGP SIGNATURE-----

--------------enigD3416911BA5FADBA91EBA899--

--===============4768573705801923171==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4768573705801923171==--
