From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 13:14:41 +0200
Message-ID: <5357A0A1.1020600@monstr.eu>
References: <20140414153849.7138699b@endymion.delvare> <20140422203209.GH12304@sirena.org.uk> <535768E1.8050609@monstr.eu> <20140423094010.17d2d763@endymion.delvare> <5357897B.6020105@monstr.eu> <20140423124838.37aa0759@endymion.delvare>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xhO59s22qC8jXRpAc7FHSrC4lG0HooV6N"
Cc: Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63363 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaDWLOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 07:14:52 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so4701878wib.5
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 04:14:50 -0700 (PDT)
In-Reply-To: <20140423124838.37aa0759@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xhO59s22qC8jXRpAc7FHSrC4lG0HooV6N
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Jean,

On 04/23/2014 12:48 PM, Jean Delvare wrote:
> Hi Michal,
>=20
> On Wed, 23 Apr 2014 11:35:55 +0200, Michal Simek wrote:
>> On 04/23/2014 09:40 AM, Jean Delvare wrote:
>>> Thanks for the information. I will send a patch adding MICROBLAZE to
>>> the dependencies. Out of curiosity, is there any way I could have fou=
nd
>>> out by myself?
>>
>> Microblaze doesn't need to be only one. I am not sure if there is
>> any AXI bridge for openrisc.
>=20
> You lost me here again :-(

at least on Zynq we have cadence macb on AXI bus. Not sure which bus
is used on Atmel. SoC vendor just buy it from Cadence and add it to
silicon.
Or for microblaze case because it is soft-core we can simple
connect Microblaze with this IP.
It means if you have any soft-core cpu which supports AXI bus
or bridge to AXI it can connect this IP.

>> IMHO you should just add COMPILE_TEST and do not try to extend that
>> list of dependencies.
>=20
> COMPILE_TEST is already present, I can't add it twice ;-) But
> COMPILE_TEST isn't supposed to be used when the architecture /
> platform / system is actually expected to possibly need the driver in
> question. If the list of possible hardware dependencies isn't well
> known, or is too complex to express, or too difficult to maintain, then=

> we have to either make it broader, or even drop it.

I am not COMPILE_TEST expert but IMHO idea was to compile all drivers
for all platforms and do not hide anything. Even I think that will
be just easier not to use COMPILE_TEST at all because it is just pain.
At least I use zero-day testing system to compile it for others architect=
ures.
And I have asked Fengguang to explicitly enable COMPILE_TEST for all plat=
forms
and do not depend that randconfig enables it.

> Originally I wanted to hide the Cadence drivers from X86 kernel
> configuration. If there's still a way to achieve that, let's do it. If
> not, we can leave the hardware dependency for ARM_AT91_ETHER and drop
> the one for MACB (and subsequently NET_CADENCE.) That's still better
> than nothing.

Any reason to hide this driver for x86?

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--xhO59s22qC8jXRpAc7FHSrC4lG0HooV6N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlNXoKEACgkQykllyylKDCHPzACeOkaceZrcDEZ7blm4krD5yiXc
Za4An0oGZkXV3nDoBN/cwt3Y9l+txQsJ
=mpoC
-----END PGP SIGNATURE-----

--xhO59s22qC8jXRpAc7FHSrC4lG0HooV6N--
