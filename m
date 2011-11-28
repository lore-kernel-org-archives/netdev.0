From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Mon, 28 Nov 2011 15:09:19 +0100
Message-ID: <4ED3960F.4040508@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4360362672195913200=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE9-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4360362672195913200==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC07729E1FA5E69B737229F80"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC07729E1FA5E69B737229F80
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/28/2011 03:03 PM, David Laight wrote:
>>>> +	for (idx =3D 0; idx < MAXDEV; idx++) {
>>> ARRAY_SIZE?
>>
>> Well, I think ARRAY_SIZE is useful to derive the number of=20
>> elements from a static array of the type:
>>
>>   static const int array[] =3D { 1, 2, 3, 4, }
>>
>> but not if its declared as:
>>
>>   static array[MAXDEV]:
>>
>> ... or have I missed something?
>=20
> Yes - if you use ARRAY_SIZE() then someone reading the code
> doesn't need to find the array definition to ensure the loop
> upper bound is correct.

Yep, that
was my intention, too.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC07729E1FA5E69B737229F80
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7Tlg8ACgkQjTAFq1RaXHPpNgCfeAbCxIfOAhw4878EO8PkQ8nU
WcwAn3TDQ+gQOY1Q4nOUJ19yHLgpQcTs
=z8H/
-----END PGP SIGNATURE-----

--------------enigC07729E1FA5E69B737229F80--

--===============4360362672195913200==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============4360362672195913200==--
