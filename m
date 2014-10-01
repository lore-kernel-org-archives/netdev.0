From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Wed, 01 Oct 2014 13:06:39 +0200
Message-ID: <542BE03F.209@pengutronix.de>
References: <20140930144950.GQ1325@katana> <542AC5B2.9040406@pengutronix.de> <20140930152550.GR1325@katana> <542AD483.2020808@pengutronix.de> <542BBF3F.2040803@ti.com> <542BBFBE.90406@pengutronix.de> <542BC42F.2010406@ti.com> <542BD116.4090809@pengutronix.de> <542BD3A7.5060200@ti.com> <542BD6F1.2020900@pengutronix.de> <20141001104317.GB1261@katana> <542BDE32.6030309@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="bhi45KI18RwM88TB6P0FRCaTVOAPHNB4D"
Cc: wg@grandegger.com, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542BDE32.6030309@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bhi45KI18RwM88TB6P0FRCaTVOAPHNB4D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/01/2014 12:57 PM, Roger Quadros wrote:
>>> ...if we just have the instance parameter in the syscon phandle, we h=
ave
>>> to put the mapping into the driver, which makes IMHO no sense, becaus=
e
>>> you have to touch the driver, if there is another SoC with the DCAN c=
ore.
>=20
> My guess is that TI won't come up with a 3rd variant so we won't have
> to touch the driver, but you never know for sure.

When I comes to 99% compatible hardware.... I've seen some.

>> ... which would be my preferred solution. I think new SoCs should have=

>> some kind of:
>>
>> 	compatible =3D "commodore,c64ultra", "bosch,d_can";
>>
>> in the DT anyhow to allow for SoC specific quirks/adjustments. And
>> custom raminit belongs to that IMO (see the ti routine getting more an=
d
>> more specific).
>>
>=20
> Right. For now we need 2 start/stop definations for the existing TI Soc=
s.
>=20
> but where to store the raminit start/stop bits? The driver_data current=
ly seems to=20
> contain the CAN type C_CAN vs D_CAN without containing it in a platform=
_data structure.
>=20
> Is it OK to create a new platform_data structure for CAN and put the ty=
pe and raminit start/stop
> bits there?

Yes, have a look how it's handled in the flexcan driver.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--bhi45KI18RwM88TB6P0FRCaTVOAPHNB4D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQr4D8ACgkQjTAFq1RaXHMxHQCcCYxWGI7CmEWMqe+zTLeJ1RQU
GzMAniNb6uuFM7euSBlm0UTInbKGPjp2
=tGQm
-----END PGP SIGNATURE-----

--bhi45KI18RwM88TB6P0FRCaTVOAPHNB4D--
