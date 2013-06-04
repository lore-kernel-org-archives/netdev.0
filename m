From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 04 Jun 2013 09:57:24 +0200
Message-ID: <51AD9DE4.7070907@monstr.eu>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com> <51918C23.7040106@yahoo.es> <20130514055256.GD22508@game.jcrosoft.org> <51AD8611.8070102@monstr.eu> <20130604064940.GA5107@pengutronix.de> <51AD9C94.4080606@atmel.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2EKHFDFQHOCEKUGKDCVSM"
Cc: Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Hein Tibosch <hein_tibosch@yahoo.es>, netdev@vger.kernel.org,
	michal.simek@xilinx.com, linux-kernel@vger.kernel.org,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	linux-arm-kernel@lists.infradead.org,
	=?ISO-8859-1?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51AD9C94.4080606@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2EKHFDFQHOCEKUGKDCVSM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/04/2013 09:51 AM, Nicolas Ferre wrote:
> On 04/06/2013 08:49, Steffen Trumtrar :
>> On Tue, Jun 04, 2013 at 08:15:45AM +0200, Michal Simek wrote:
>>> On 05/14/2013 07:52 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>> On 08:58 Tue 14 May     , Hein Tibosch wrote:
>>>>> On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>>>> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.c=
om> wrote:
>>>>>>
>>>>>>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>>>>>>> introduces clear-on-write on ISR register. This behavior is not a=
lways
>>>>>>> implemented when using Cadence MACB/GEM and is breaking other pla=
tforms.
>>>>>>> We are using a new Device Tree compatibility string and a capabil=
ity
>>>>>>> property to actually activate this clear-on-write behavior on ISR=
=2E
>>>>>>>
>>>>>>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>>>>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>>>>> can we detect it via the IP?
>>>>>
>>>>> This was my first proposal, have it based on the value of MACB's
>>>>> register 'MID' (offset 0x00fc, lower 16 bits).
>>>>> On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119
>>>>>
>>>>> So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revi=
sion
>>>>> equals to 0x00000119?
>>>> so no it will not work
>>>>
>>>> as the gem on sama5 is 00020119
>>>>
>>>> so version 0x119 too
>>>>
>>>> nico
>>>> Acked-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
>>>
>>> Was this added to any queue or branch?
>>> I would like to enable macb for zynq and not sure if "cdns,zynq-7000-=
gem"
>>> compatible string goes to mainline.
>>>
>>
>> Hi!
>>
>> This is already in next, but you can use the default compatible as the=

>=20
> Even more: already in Linus' tree!

Ah I see. v2 is in thunderbird in the same thread and I didn't check this=

version for compatible string.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2EKHFDFQHOCEKUGKDCVSM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGtneQACgkQykllyylKDCHQqwCghnvM2+i5sMOA13K9unWDOupu
EFgAoJFhjkUJtxG9SG3BUplOs6aF6R3I
=PVh7
-----END PGP SIGNATURE-----

------enig2EKHFDFQHOCEKUGKDCVSM--
