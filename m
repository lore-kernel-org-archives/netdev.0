From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 04 Jun 2013 08:54:59 +0200
Message-ID: <51AD8F43.4090107@monstr.eu>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com> <51918C23.7040106@yahoo.es> <20130514055256.GD22508@game.jcrosoft.org> <51AD8611.8070102@monstr.eu> <20130604064940.GA5107@pengutronix.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2FKLTDHLEDVWRKPLTTRHN"
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Hein Tibosch <hein_tibosch@yahoo.es>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	michal.simek@xilinx.com, linux-kernel@vger.kernel.org,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	linux-arm-kernel@lists.infradead.org,
	=?ISO-8859-1?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130604064940.GA5107@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2FKLTDHLEDVWRKPLTTRHN
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/04/2013 08:49 AM, Steffen Trumtrar wrote:
> On Tue, Jun 04, 2013 at 08:15:45AM +0200, Michal Simek wrote:
>> On 05/14/2013 07:52 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>> On 08:58 Tue 14 May     , Hein Tibosch wrote:
>>>> On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>>> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.co=
m> wrote:
>>>>>
>>>>>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>>>>>> introduces clear-on-write on ISR register. This behavior is not al=
ways
>>>>>> implemented when using Cadence MACB/GEM and is breaking other plat=
forms.
>>>>>> We are using a new Device Tree compatibility string and a capabili=
ty
>>>>>> property to actually activate this clear-on-write behavior on ISR.=

>>>>>>
>>>>>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>>>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>>>> can we detect it via the IP?
>>>>
>>>> This was my first proposal, have it based on the value of MACB's
>>>> register 'MID' (offset 0x00fc, lower 16 bits).
>>>> On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119
>>>>
>>>> So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revis=
ion
>>>> equals to 0x00000119?
>>> so no it will not work
>>>
>>> as the gem on sama5 is 00020119
>>>
>>> so version 0x119 too
>>>
>>> nico=20
>>> Acked-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
>>
>> Was this added to any queue or branch?
>> I would like to enable macb for zynq and not sure if "cdns,zynq-7000-g=
em"
>> compatible string goes to mainline.
>>
>=20
> Hi!
>=20
> This is already in next, but you can use the default compatible as the
> DCR1 is used instead of DT binding.

Ah ok. It was added there without cdns,zynq-7000-gem compatible string.

BTW: I have asked Soren to update your patch on the top of his clock chan=
ges.

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2FKLTDHLEDVWRKPLTTRHN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGtj0MACgkQykllyylKDCG++QCgmy5yJFwoDfxEzAUfG/99EA+S
A+EAniC0l05MdYBA8opbWkFj8uEjCR4A
=gFG1
-----END PGP SIGNATURE-----

------enig2FKLTDHLEDVWRKPLTTRHN--
