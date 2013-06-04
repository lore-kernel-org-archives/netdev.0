From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 04 Jun 2013 08:15:45 +0200
Message-ID: <51AD8611.8070102@monstr.eu>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com> <51918C23.7040106@yahoo.es> <20130514055256.GD22508@game.jcrosoft.org>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2PRQTPGOBTCJVGUUXBFXF"
Cc: Hein Tibosch <hein_tibosch@yahoo.es>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	michal.simek@xilinx.com, linux-kernel@vger.kernel.org,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	=?ISO-8859-1?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130514055256.GD22508@game.jcrosoft.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2PRQTPGOBTCJVGUUXBFXF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/14/2013 07:52 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 08:58 Tue 14 May     , Hein Tibosch wrote:
>> On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.com>=
 wrote:
>>>
>>>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>>>> introduces clear-on-write on ISR register. This behavior is not alwa=
ys
>>>> implemented when using Cadence MACB/GEM and is breaking other platfo=
rms.
>>>> We are using a new Device Tree compatibility string and a capability=

>>>> property to actually activate this clear-on-write behavior on ISR.
>>>>
>>>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>> can we detect it via the IP?
>>
>> This was my first proposal, have it based on the value of MACB's
>> register 'MID' (offset 0x00fc, lower 16 bits).
>> On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119
>>
>> So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revisio=
n
>> equals to 0x00000119?
> so no it will not work
>=20
> as the gem on sama5 is 00020119
>=20
> so version 0x119 too
>=20
> nico=20
> Acked-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>

Was this added to any queue or branch?
I would like to enable macb for zynq and not sure if "cdns,zynq-7000-gem"=

compatible string goes to mainline.

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2PRQTPGOBTCJVGUUXBFXF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGthhEACgkQykllyylKDCG2bgCgmrB4vIP6i/yt0ExEIzxBW6Mb
yLwAn2LxfEeW8ypXD9wW/T13WW+jmEyZ
=AzeM
-----END PGP SIGNATURE-----

------enig2PRQTPGOBTCJVGUUXBFXF--
