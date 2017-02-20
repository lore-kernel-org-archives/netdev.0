From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
Date: Mon, 20 Feb 2017 17:44:39 +0100
Message-ID: <eb9c2ef8-abea-9a93-bfa3-9c3bc849a022@pengutronix.de>
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
 <b1140be9-1811-1512-b32e-436e8bb25824@hartkopp.net>
 <20170220163714.uj5el22c5tq47cul@piout.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="KVT9wNp506mEuBQ1DsUSxojTLw21paHFB"
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        fvallee@eukrea.fr, wg@grandegger.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        boris.brezillon@free-electrons.com, nicolas.ferre@atmel.com
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170220163714.uj5el22c5tq47cul@piout.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KVT9wNp506mEuBQ1DsUSxojTLw21paHFB
Content-Type: multipart/mixed; boundary="cM9lxPlI3PxlCWJ4VPS2H3rIxDwHJ0vJd";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>, fvallee@eukrea.fr,
 wg@grandegger.com, linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com,
 nicolas.ferre@atmel.com
Message-ID: <eb9c2ef8-abea-9a93-bfa3-9c3bc849a022@pengutronix.de>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
 <b1140be9-1811-1512-b32e-436e8bb25824@hartkopp.net>
 <20170220163714.uj5el22c5tq47cul@piout.net>
In-Reply-To: <20170220163714.uj5el22c5tq47cul@piout.net>

--cM9lxPlI3PxlCWJ4VPS2H3rIxDwHJ0vJd
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/20/2017 05:37 PM, Alexandre Belloni wrote:
> On 19/02/2017 at 16:37:50 +0100, Oliver Hartkopp wrote:
>> Fortunately I was contacted by Bosch this Friday as they want to contr=
ibute
>> a driver upgrade to support IP cores up to 3.2.x.
>> Additionally their plan is to use Device Tree information to determine=
 the
>> IP core revision - or at least to cross check its information with the=

>> register information used in your suggestion.
>=20
> My opinion is that is is not really useful. Either we use the version
> info from the register or DT. But that is probably a matter of taste an=
d
> you are the maintainer :)

I see no benefit of holding the version number in the DT, as long as the
version of the HW can be auto discovered properly.

>> For that reason I would suggest to wait for the driver updates from Bo=
sch
>> instead of adding an incomplete fix for only one change of eleven.

> Well, having something working right now is still better that nothing. =
I
> think it is worth having that patch now so CAN is working on our
> platforms.
>=20
> Everything else can probably be built on top of it anyway.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cM9lxPlI3PxlCWJ4VPS2H3rIxDwHJ0vJd--

--KVT9wNp506mEuBQ1DsUSxojTLw21paHFB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlirHPgACgkQHv7KIOw4
HPai/AgAhzGHniTO15xBEdQ1NC7mO/BIAjw9sbOosSRKrtgRN/dwESpvSckYuGhm
XKFg1qssEil45Td8eSnPVpVbOp4gGJ3TYPl31GVGSeHkkUP+sdKVoDIjc0CRNrhQ
Ta3r3SHgTP4+3Ygy+gg91nY353vdHurYY6e0T1rVuvbcKXHD/b3908B9LbRZfCxy
1Q3qOfKXk9LYnHlQrR0TVdYImXCs50hjPLITuTFltPm4Jj17sqtqcpHYD00x5VUx
uRufk+jX1ldJ+KVQrfpPMB4l0TpsJoUTnC4sQ59qWcEmmmvMcy+i8q990hLZXm2W
XflGRf9verwyP8bXzwePnle1EcCHrw==
=hRXK
-----END PGP SIGNATURE-----

--KVT9wNp506mEuBQ1DsUSxojTLw21paHFB--
