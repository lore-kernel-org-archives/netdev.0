From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Wed, 25 Feb 2015 12:50:41 +0100
Message-ID: <54EDB711.1090608@monstr.eu>
References: <54EB34E7.7060400@monstr.eu>	<1424763572-23317-1-git-send-email-achandran@mvista.com>	<54ED9DA8.3040809@monstr.eu> <CAFdej00df2gcUXVTnR34M6E+Mr7ctgjHgMisEpJUsZK6kf_CpA@mail.gmail.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="sP05mOQowEowFAf49aqg5tCVXCvjQe1MG"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arun Chandran <achandran@mvista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFdej00df2gcUXVTnR34M6E+Mr7ctgjHgMisEpJUsZK6kf_CpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sP05mOQowEowFAf49aqg5tCVXCvjQe1MG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

>> endian mode all the time. But the logic for detecting this on CPU is c=
orrect and this is what
>> you need to do on Zynq. You are writing big endian value to little end=
ian register and read it back
>> to see if it was correctly written or not.
>=20
> Just curious; will the same code work without change on a CPU with Big
> endian IP?
> (ie. If zynq hardware comes with only one change; IP configured in BE;
>  will the driver be needing further changes?)

Depends on HW setup and architecture which you want to use.
Let's say test could be to have Microblaze in PL in BE mode (not supporte=
d by tools)
and bridge to axi. Then depends on Linux kernel how IO functions are impl=
emented.
That's why it is hard to say yes/no.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--sP05mOQowEowFAf49aqg5tCVXCvjQe1MG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTttxEACgkQykllyylKDCEQyQCdFRKb0wiNFNlHmDJznewlgpdQ
ZOsAniVeoFc/B6okJ8aaKLZXoD0Vx5KF
=zTLn
-----END PGP SIGNATURE-----

--sP05mOQowEowFAf49aqg5tCVXCvjQe1MG--
