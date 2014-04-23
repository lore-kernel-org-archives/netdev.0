From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 11:35:55 +0200
Message-ID: <5357897B.6020105@monstr.eu>
References: <20140414153849.7138699b@endymion.delvare> <20140422203209.GH12304@sirena.org.uk> <535768E1.8050609@monstr.eu> <20140423094010.17d2d763@endymion.delvare>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="FR6Sxq7L706Cdsk2NwUwITGhfkTkkH9PF"
Cc: Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56018 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbaDWJgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 05:36:06 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so537815eei.5
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 02:36:04 -0700 (PDT)
In-Reply-To: <20140423094010.17d2d763@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FR6Sxq7L706Cdsk2NwUwITGhfkTkkH9PF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/23/2014 09:40 AM, Jean Delvare wrote:
> Hi Mark, Michal,
>=20
> On Wed, 23 Apr 2014 09:16:49 +0200, Michal Simek wrote:
>> On 04/22/2014 10:32 PM, Mark Brown wrote:
>>> On Mon, Apr 14, 2014 at 03:38:49PM +0200, Jean Delvare wrote:
>>>> The Cadence ethernet chipsets are only used on specific ARM
>>>> architectures. Add Kconfig dependencies so that drivers for these
>>>> chipsets are only buildable on the relevant architectures.
>>>
>>> Are you sure they're not used on any of the FPGA platforms like
>>> Microblaze?
>=20
> I'm not sure of anything, embedded isn't my area.
>=20
>>> Cadence are an IP company,
>=20
> I can't parse this, sorry. What is an "IP company"?

Company which is creating this piece of HW which is called IP.


>>> might be worth having a FPGA
>>> Kconfig that architectures commonly deployed with lots of soft IPs ca=
n
>>> select and the IPs depend on rather than building a custom list for e=
ach
>>> IP.
>=20
> What are "soft IPs"? I'm afraid I wouldn't be able to translate your
> proposal into a patch, I just don't understand what you mean exactly.

Microblaze is soft-core cpu or soft IP if you like. It means it is writte=
n
in VHDL/Verilog or in different hardware description language.

>> macb driver can be used by Microblaze too.
>=20
> Thanks for the information. I will send a patch adding MICROBLAZE to
> the dependencies. Out of curiosity, is there any way I could have found=

> out by myself?

Microblaze doesn't need to be only one. I am not sure if there is
any AXI bridge for openrisc.
IMHO you should just add COMPILE_TEST and do not try to extend that
list of dependencies.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--FR6Sxq7L706Cdsk2NwUwITGhfkTkkH9PF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlNXiXsACgkQykllyylKDCGCrwCgmiMGS2y/6i1Zr455Io+vwsJF
lj0Aniy+82G3O47ErL56Q1nNuNS32qKU
=vfSA
-----END PGP SIGNATURE-----

--FR6Sxq7L706Cdsk2NwUwITGhfkTkkH9PF--
