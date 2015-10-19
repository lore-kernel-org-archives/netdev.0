From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Mon, 19 Oct 2015 09:31:11 +0200
Message-ID: <56249C3F.3080000@pengutronix.de>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
 <56249491.4020009@pengutronix.de> <56249B58.6090100@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="RhfRqRK9DH9GN6VbLvL7VA3a5JxxOrk3j"
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org
To: hs@denx.de, anton.a.glukhov@gmail.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56249B58.6090100@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RhfRqRK9DH9GN6VbLvL7VA3a5JxxOrk3j
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/19/2015 09:27 AM, Heiko Schocher wrote:
>>>   .../devicetree/bindings/net/can/ti_hecc-can.txt    | 20 ++++++++++
>>>   arch/arm/boot/dts/am3517.dtsi                      | 13 +++++++
>>>   drivers/net/can/ti_hecc.c                          | 45 +++++++++++=
++++++++++-
>>>   3 files changed, 76 insertions(+), 2 deletions(-)
>>>   create mode 100644 Documentation/devicetree/bindings/net/can/ti_hec=
c-can.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/can/ti_hecc-can.tx=
t b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>> new file mode 100644
>>> index 0000000..09fab59
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
>>> @@ -0,0 +1,20 @@
>>> +* TI HECC CAN *
>>> +
>>> +Required properties:
>>> +  - compatible: Should be "ti,hecc"
>>
>> We usually put the name of the first SoC this IP core appears in to th=
e
>> compatible.
>=20
> Ok, so "ti,am335xx-hecc" would be OK?
> @Anton: you used "am35x" ... it should be "am35xx"

The "xx" is not okay. Give precisely the first SoC Version this IP core
was implemented in.

>=20
>>> +  - reg: Should contain CAN controller registers location and length=

>>> +  - interrupts: Should contain IRQ line for the CAN controller
>>
>> I'm missing the description of the ti,* properties. I think they are
>> required, too. Although the code doesn't enforce it.
>=20
> Ok.
>=20
>>> +
>>> +Example:
>>> +
>>> +	can0: hecc@5c050000 {
>>> +		compatible =3D "ti,hecc";
>>> +		reg =3D <0x5c050000 0x4000>;
>>> +		interrupts =3D <24>;
>>> +		ti,hecc_scc_offset =3D <0>;
>>> +		ti,hecc_scc_ram_offset =3D <0x3000>;
>>> +		ti,hecc_ram_offset =3D <0x3000>;
>>> +		ti,hecc_mbx_offset =3D <0x2000>;
>>> +		ti,hecc_int_line =3D <0>;
>>> +		ti,hecc_version =3D <1>;
>>
>> Versioning in the OF world is done via the compatible. Are the offsets=
 a
>> per SoC parameter? I'm not sure if it's better to put
>> the offsets into the driver.
>=20
> I am unsure here too..

The devicetree people will hopefully help here.

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--RhfRqRK9DH9GN6VbLvL7VA3a5JxxOrk3j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJJxAAAoJEP5prqPJtc/HVrsH/24NElJepIIymxz/kYbei8YI
+mT6IWc3rULUVCEy+Lp92NcajDCIXIK/CFDqfavKYAkgvlqLOYxtKha9ZsXfEoW2
YaxqB4lS2lrxlNniCWGRY+rIf7BsTTmRl5nZgAMueR/mvMIv8B/qGBStSPxp+LDJ
As0TyzeF5fEDpvldsAZfBeniUX7xT+Be4C/t8V6335EdqqKHnnnmhNz1syNtA2of
WDHwWCae+rngZw6am+FFhsDVlTRtD+OSjzC10U95FixOfaCgCX8SMp/PZOPKzVIV
P8qKaup+ncljy3dwwIeHl2CAJM3zbY93v1mgRarPXivuX4OXXi6e/F7f0vbf+wc=
=VWj/
-----END PGP SIGNATURE-----

--RhfRqRK9DH9GN6VbLvL7VA3a5JxxOrk3j--
