From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 12:44:00 +0200
Message-ID: <4C1B4DF0.2090103@pengutronix.de>
References: <20100617105201.GA2015@bluebox.local>	<4C1B4098.3090800@grandegger.com>
	<4C1B4796.3060506@pengutronix.de> <4C1B4B85.3010905@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6152072698511481419=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C1B4B85.3010905-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
--===============6152072698511481419==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCF763389D5E14467CCEC003D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCF763389D5E14467CCEC003D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> On 06/18/2010 12:16 PM, Marc Kleine-Budde wrote:
>> Wolfgang Grandegger wrote:
>>> Hi Hans-J=FCrgen,
>>>
>>> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>>>> This adds a driver for FlexCAN based CAN controllers,
>>>> e.g. found in Freescale i.MX35 SoCs.
>>>>
>>>> The original version of this driver was posted by Sascha Hauer in Ju=
ly 2009:
>>>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>>>
>>>> I took this version, added NAPI support, and fixed some problems fou=
nd
>>>> during testing. Well, here is the result. Please review.
>>> I briefly browsed the patch and various bits and pieces are missing o=
r
>>> not correctly implemented. Marc already pointed out a few of them:
>>>
>>> - I do not find can_put/get_echo_skb functions in the code. How is
>>>   IFF_ECHO supposed to work?
>> the driver uses hardware loopback
>=20
> OK, then
>=20
>   dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
>=20
> should be used (and TX_ECHO_SKB_MAX removed) in Hans-J=FCrgens driver.
>=20
>>> - Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()
>>>   seems to be missing.
>>>
>>> - Make use of alloc_can_skb() and alloc_can_err_skb().
>> the last two points are already addressed in my version of the driver.=

>=20
> I do not see support for CAN_CTRLMODE_BERR_REPORTING in your driver
> (which has nothing to do with do_get_berr_counter).

oh yes...sorry, got confused.

However I implemented CAN_CTRLMODE_BERR_REPORTING, i.e. turning of the
bit error interrupts by default. This has the effect that no bus warning
and bus passive interrupt was signalled.

I should add a comment to my driver.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCF763389D5E14467CCEC003D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkwbTfAACgkQjTAFq1RaXHM6XQCfWyhdOT0UIW6GuBkL7kK3ty46
3XoAn2PUTIiLz+JODDt5PWFHascq9dHA
=IUZY
-----END PGP SIGNATURE-----

--------------enigCF763389D5E14467CCEC003D--

--===============6152072698511481419==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6152072698511481419==--
