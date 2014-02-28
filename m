From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 12:50:55 +0100
Message-ID: <5310781F.1000005@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>	<52DCE9E4.7010209@pengutronix.de>	<52E3148E.2010608@cogentembedded.com>	<52FCB6C5.6020001@pengutronix.de>	<53069445.80408@cogentembedded.com>	<5310521E.6000708@pengutronix.de>	<53107007.7050802@cogentembedded.com>	<531074F5.8090702@pengutronix.de> <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CDBD9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="tU6ADj3THQ7Av7AaOcBcRQngkOO3BAleG"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Geert Uytterhoeven' <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CDBD9@AcuExch.aculab.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tU6ADj3THQ7Av7AaOcBcRQngkOO3BAleG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2014 12:47 PM, David Laight wrote:
> From: Geert Uytterhoeven
>> On Fri, Feb 28, 2014 at 12:37 PM, Marc Kleine-Budde <mkl@pengutronix.d=
e> wrote:
>>>>> A 32 bit read/modify/write is a standard operation, nothing special=
, no
>>>>> need to worry about byte swapping or anything like this.
>>>>
>>>>    Oh, really? 8-)
>>>>    Don't you know that read[bwlq]() assume little-endian memory layo=
ut
>>>> and to read from big-endian 32-bit register one normally needs readl=
_be()?
>>>
>>> I assume you are on little endian ARM only (for now).
>>>
>>> If you use a standard 32 bit read, then modify the correct bits in th=
at
>>> 32 bit word and write it back, with the corresponding 32 bit write
>>> everything should be fine. For this usecase you just have yo figure o=
ut
>>> which 24 of the 32 bit are the one you have to change and which are t=
he
>>> 8 that must not be modified.
>>>
>>> Looking at the register layout:
>>>
>>>> +     u8 bcr[3];      /* Bit Configuration Register */
>>>> +     u8 clkr;        /* Clock Select Register */
>>>
>>> I think clkr would be the lowest 8 bit and bcr[] are the upper 24.
>>
>> That would be the outcome on big endian ;-)
>=20
> Looks to me as though it should be defined as a 32bit field and then
> the appropriate bit definitions and masks applied.

Ack, 32bit yes, but no field (as in http://en.wikipedia.org/wiki/Bit_fiel=
d).

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--tU6ADj3THQ7Av7AaOcBcRQngkOO3BAleG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMQeB8ACgkQjTAFq1RaXHPLXACfbdY3PZXzzlIhGip1AN4lADPC
EnIAoId4OfLuS8GXU+WjnOPizp+vdS6Y
=fjAc
-----END PGP SIGNATURE-----

--tU6ADj3THQ7Av7AaOcBcRQngkOO3BAleG--
