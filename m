From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 09:16:49 +0200
Message-ID: <535768E1.8050609@monstr.eu>
References: <20140414153849.7138699b@endymion.delvare> <20140422203209.GH12304@sirena.org.uk>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="cVdubuLl8mDHNkcTg2P2xIL6L1HShf7Ep"
Cc: Jean Delvare <jdelvare@suse.de>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:45914 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbaDWHQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 03:16:53 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so394258eek.15
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 00:16:52 -0700 (PDT)
In-Reply-To: <20140422203209.GH12304@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cVdubuLl8mDHNkcTg2P2xIL6L1HShf7Ep
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/22/2014 10:32 PM, Mark Brown wrote:
> On Mon, Apr 14, 2014 at 03:38:49PM +0200, Jean Delvare wrote:
>> The Cadence ethernet chipsets are only used on specific ARM
>> architectures. Add Kconfig dependencies so that drivers for these
>> chipsets are only buildable on the relevant architectures.
>=20
> Are you sure they're not used on any of the FPGA platforms like
> Microblaze?  Cadence are an IP company, might be worth having a FPGA
> Kconfig that architectures commonly deployed with lots of soft IPs can
> select and the IPs depend on rather than building a custom list for eac=
h
> IP.

macb driver can be used by Microblaze too.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--cVdubuLl8mDHNkcTg2P2xIL6L1HShf7Ep
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlNXaOEACgkQykllyylKDCEnPACeMbiQbXGI7wI+vXHEJNbmmHQK
Y7AAnRRciorMlb97SlEiN+WQTtnhC2lJ
=9UTi
-----END PGP SIGNATURE-----

--cVdubuLl8mDHNkcTg2P2xIL6L1HShf7Ep--
