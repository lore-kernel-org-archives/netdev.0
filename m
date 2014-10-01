From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Wed, 01 Oct 2014 12:01:58 +0200
Message-ID: <542BD116.4090809@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana> <542AB6E9.9000907@ti.com> <20140930141909.GP1325@katana> <542ABC90.7010900@pengutronix.de> <20140930144950.GQ1325@katana> <542AC5B2.9040406@pengutronix.de> <20140930152550.GR1325@katana> <542AD483.2020808@pengutronix.de> <542BBF3F.2040803@ti.com> <542BBFBE.90406@pengutronix.de> <542BC42F.2010406@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="0lMhuXrKqs2bPuKTGWdndPiACCwEPllhW"
Cc: wg@grandegger.com, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542BC42F.2010406@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0lMhuXrKqs2bPuKTGWdndPiACCwEPllhW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/01/2014 11:06 AM, Roger Quadros wrote:
> On 10/01/2014 11:47 AM, Marc Kleine-Budde wrote:
>> On 10/01/2014 10:45 AM, Roger Quadros wrote:
>>> On 09/30/2014 07:04 PM, Marc Kleine-Budde wrote:
>>>> On 09/30/2014 05:25 PM, Wolfram Sang wrote:
>>>>>
>>>>>> Yes, but syscon_regmap_lookup_by_phandle() doesn't need any suppor=
t for
>>>>>> additional parameters. Have a look at:
>>>>>>
>>>>>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>>>>>>
>>>>>> First get the regmap, then the 1st argument is the offset in the r=
egmap,
>>>>>> the 2nd and 3rd could be the bits.
>>>>>
>>>>> So, for one driver the extra arguments are: <reg> <start_bit> <stop=
_bit>
>>>>> For another driver (the stmmac example): <reg_offset> <reg_shift>
>>>>
>>>> The DCAN's "reg" is a "reg_offset" as in the stmmc.
>>>>
>>>> Roger, can we derive both start and done bit from a common reg_shift=
?
>>>
>>> I'm sorry I didn't understand what you meant.
>>>
>>> <&syscon_phandl> <reg offset> <start bit> <stop bit> should work well=
 for us.
>>> Even though reg offset is the same for both the DCAN instances.
>>
>> What's start bit and stop bit for instance 0 and 1 on that SoC that ha=
s
>> two instances?
>>
>=20
> we have 3 SoCs at the moment, all have 2 DCAN instances.
>=20
> AM33xx & AM43xx
> instance	start	stop
> 1		0	8
> 2		1	9=09

If we use a 0-based numbering for the instances:
instance	start		stop
0		(0 << instance)	(8 << instance)
1		(0 << instance)	(8 << instance)

> DRA7xx
> instance	start	stop
> 1		3	1
> 2		5	2
                ^
5 or 4?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0lMhuXrKqs2bPuKTGWdndPiACCwEPllhW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQr0RYACgkQjTAFq1RaXHOgowCeJffd0KaAiKCPxkCYCGUP/3OT
Q10AnAu5T/9FUNWSbx2LcAHPEfPLrmCt
=/zRd
-----END PGP SIGNATURE-----

--0lMhuXrKqs2bPuKTGWdndPiACCwEPllhW--
