From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC PATCH net-next] can-gw: add a variable limit for CAN frame
 routings
Date: Tue, 08 Jan 2013 12:56:32 +0100
Message-ID: <50EC0970.10806@pengutronix.de>
References: <50EB4377.6030306@hartkopp.net> <50EBDB94.3000705@pengutronix.de> <50EBF453.7020408@volkswagen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC7A3F04446D77181CBF4726B"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux CAN List <linux-can@vger.kernel.org>
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <50EBF453.7020408@volkswagen.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC7A3F04446D77181CBF4726B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/08/2013 11:26 AM, Oliver Hartkopp wrote:
> Am 08.01.2013 09:40, schrieb Marc Kleine-Budde:
>> On 01/07/2013 10:51 PM, Oliver Hartkopp wrote:
>=20
>=20
>>>
>>>   static __init int cgw_module_init(void)
>>>   {
>>> -    printk(banner);
>>> +    /* sanitize given module parameter */
>>> +    if (max_hops < 1)
>>> +        max_hops =3D 1;
>>> +
>>> +    if (max_hops > CAN_GW_MAX_HOPS)
>>> +        max_hops =3D CAN_GW_MAX_HOPS;
>>
>> You can make use of clamp(val, min, max) here.
>>
>=20
> ok.
>=20
> I added
>=20
>     #include <linux/kernel.h>
>=20
> where clamp is defined and reduced the code above to
>=20
> clamp_t(unsigned int, max_hops, CAN_GW_MIN_HOPS, CAN_GW_MAX_HOPS);
>=20
> Unfortunately clamp(max_hops, CAN_GW_MIN_HOPS, CAN_GW_MAX_HOPS) did not=

> work.
>=20
> =3D> (warning: comparison of distinct pointer types lacks a cast)

Defines are probably unsinged longs, by default.

> Will send the v2 when there're no other remarks tommorrow.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC7A3F04446D77181CBF4726B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlDsCXAACgkQjTAFq1RaXHNR+QCaA8mNWhw5OEa7o4Jc8n1vFKxM
W+UAniEmmb5xTZgmktDsWCaz400OUzO/
=BYiq
-----END PGP SIGNATURE-----

--------------enigC7A3F04446D77181CBF4726B--
