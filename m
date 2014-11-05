From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 7/8] net: can: c_can: Add support for TI DRA7 DCAN
Date: Wed, 05 Nov 2014 14:43:39 +0100
Message-ID: <545A298B.6090505@pengutronix.de>
References: <1415096461-25576-1-git-send-email-rogerq@ti.com> <1415096461-25576-8-git-send-email-rogerq@ti.com> <545A2679.2000905@pengutronix.de> <545A27E8.9090600@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mJApGBNlnFX4hMixwNw970i3xmK981ES0"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <545A27E8.9090600@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mJApGBNlnFX4hMixwNw970i3xmK981ES0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 02:36 PM, Roger Quadros wrote:
> On 11/05/2014 03:30 PM, Marc Kleine-Budde wrote:
>> On 11/04/2014 11:21 AM, Roger Quadros wrote:
>>> DRA7 SoC has 2 CAN IPs. Provide compatible IDs and RAMINIT
>>> register data for both.
>>
>> My understanding of the discussion with Wolfram was:
>> - We should put the number of the Interface into to DT as a regmap
>>   parameter.
>> - We put the method how to find the correct bits into the DT, via the
>>   compatible.
>>
>> So for both CAN instances on the DRA7 we have a single compatible
>> "ti,dra7-d_can" and in the driver a mechanism that translates the numb=
er
>> of the instance into the needed bit offsets, e.g. via two arrays.
>>
>=20
> OK. I'll revise this series.
>=20
> The new syscon-raminit property will be like
> syscon-raminit =3D <syscon_phandle raminit-reg-offset dcan-interface-nu=
mber>;

Yes. Wolfram?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mJApGBNlnFX4hMixwNw970i3xmK981ES0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWimLAAoJECte4hHFiupUe3AP/jU5A7EUah+AGbdM8xboevir
GI7G4eex+AVXjrKys/zbR2BJvg5BQ2r/w7llG+T7o3sR5QNqeUbgeGEvlrRDrsya
FL/sp7P74zY9QChrVI6bIYHPIgeM062eKX6uD/G4R2j3vehVawRSAxW7n0nrVEIS
ypnlC44f04fiPR2y0PtH6ZtTSdz5GC5GKAg4vTptsX/aR039oGsiPG6z5iuAiSCO
SPIeXKUfA54JNlU4739SvYZLwCtn19fn8iGDjuod3f62n3G94Phc1zXsUoIO4ccm
HmjHHTc5jK6ZqzMmbsch1Dzd1arSMCMAStfR72iqaiAv3kTt2/z4izb/D6R8g6NV
zwU5xDqLMr3aC5HIds0ywUFcXeZQvCy80uG7yYl30B7WDlTDK1Q0Yv5HSisms7zp
L4oVa54dBwJohbnOvu+0w78wJLADWSXKwDc9VfEld00BS4u/DXXdCoJrtZKS7+Vi
5PpzLDRPt67Y8O9vh/xXhMmkkFasjNUqp055sYu+XZE6D+ObkYMA62Fn+kVGjJwG
5KUbmSLIYlJXJDa+L2JqcWgMauRhQ9Bl1SiE+Q+oxZ4mgvrVeu+VHKl55Xl4j5iO
P6Yp363Nf94mp59r1c5TAi8Rc+6ip4AjWQZ+w8FgWHgHEIrCZJSxRqrk5bkxsdK1
3AXc2HK1ZE+hhuaqkxxx
=ZKql
-----END PGP SIGNATURE-----

--mJApGBNlnFX4hMixwNw970i3xmK981ES0--
