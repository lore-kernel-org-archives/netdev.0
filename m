From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 3/3] can: at91_can: make can_id of mailbox 0 configurable
Date: Tue, 11 Jan 2011 13:04:40 +0100
Message-ID: <4D2C4758.3030600@pengutronix.de>
References: <1294741688-22699-1-git-send-email-mkl@pengutronix.de>	<1294741688-22699-4-git-send-email-mkl@pengutronix.de>
	<20110111115739.GA25741@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8294830586522803747=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110111115739.GA25741-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
--===============8294830586522803747==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig177AB3C2572BFA3C51ACD374"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig177AB3C2572BFA3C51ACD374
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2011 12:57 PM, Wolfram Sang wrote:
> On Tue, Jan 11, 2011 at 11:28:08AM +0100, Marc Kleine-Budde wrote:
>> Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
>> "AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailb=
ox
>> 0 may be send under certain conditions (even if disabled or in rx mode=
).
>>
>> The workaround in the errata suggests not to use the mailbox and load =
it
>> with a unused identifier.
>>
>> This patch implements the second part of the workaround. A sysfs entry=

>> "mb0_id" is introduced. While the interface is down it can be used to
>> configure the can_id of mailbox 0. The default value id 0x7ff.
>>
>> In order to use an extended can_id add the CAN_EFF_FLAG (0x80000000U)
>> to the can_id. Example:
>>
>> - standard id 0x7ff:
>> echo 0x7ff      > /sys/class/net/can0/mb0_id
>>
>> - extended if 0x1fffffff:
>> echo 0x9fffffff > /sys/class/net/can0/mb0_id
>=20
> Maybe put something like this also in Documentation/ABI/testing? Perhap=
s

Good point.

> a bit more explicit: Can this interface be used? Should it be used? Mus=
t
> it be used?

It can be used if your aren't satisfied with with default id of 0x7ff.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig177AB3C2572BFA3C51ACD374
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk0sR1gACgkQjTAFq1RaXHO9BACWJyzNNHQt9zEokVF70uL3P+y/
7gCdFQDYI9FyONuWi6H6dWS3Q+ndcVE=
=4YzO
-----END PGP SIGNATURE-----

--------------enig177AB3C2572BFA3C51ACD374--

--===============8294830586522803747==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8294830586522803747==--
