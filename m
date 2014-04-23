From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 15:16:04 +0200
Message-ID: <5357BD14.1000608@monstr.eu>
References: <20140414153849.7138699b@endymion.delvare> <20140422203209.GH12304@sirena.org.uk> <535768E1.8050609@monstr.eu> <20140423094010.17d2d763@endymion.delvare> <5357897B.6020105@monstr.eu> <20140423124838.37aa0759@endymion.delvare> <5357A0A1.1020600@monstr.eu> <20140423113402.GV12304@sirena.org.uk>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DUdhqRqXS4Ha9aQXdsQq9Qh7burPm8hxc"
Cc: Jean Delvare <jdelvare@suse.de>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:63791 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbaDWNQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:16:09 -0400
Received: by mail-wi0-f169.google.com with SMTP id hm4so4520090wib.2
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 06:16:07 -0700 (PDT)
In-Reply-To: <20140423113402.GV12304@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DUdhqRqXS4Ha9aQXdsQq9Qh7burPm8hxc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/23/2014 01:34 PM, Mark Brown wrote:
> On Wed, Apr 23, 2014 at 01:14:41PM +0200, Michal Simek wrote:
>> On 04/23/2014 12:48 PM, Jean Delvare wrote:
>=20
>>> Originally I wanted to hide the Cadence drivers from X86 kernel
>>> configuration. If there's still a way to achieve that, let's do it. I=
f
>>> not, we can leave the hardware dependency for ARM_AT91_ETHER and drop=

>>> the one for MACB (and subsequently NET_CADENCE.) That's still better
>>> than nothing.
>=20
>> Any reason to hide this driver for x86?
>=20
> Distro maintainers like Jean are complaining about build times for thei=
r
> kernels if they enable absolutely everything so if they're never likely=

> to see any hardware using something they want to skip it.

Is there any reasonable solution for this?
1. One group is saying use COMPILE_TEST for every driver to have better
coverage.
2. Next group is saying I don't want to build everything for my arch.

Fixing Kconfig to say !x86 is probably not the right way to go.

Isn't it enough not to enable absolutely everything?

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--DUdhqRqXS4Ha9aQXdsQq9Qh7burPm8hxc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlNXvRQACgkQykllyylKDCHamgCdGpf2e4crdyeVIf+TmjRIMSfN
YAsAoIjpa9lZTGYRCTKqRsPcCbHHClRN
=FK2F
-----END PGP SIGNATURE-----

--DUdhqRqXS4Ha9aQXdsQq9Qh7burPm8hxc--
