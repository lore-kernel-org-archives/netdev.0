From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: r8169 driver cause ssh failure
Date: Mon, 13 May 2013 08:11:42 +0200
Message-ID: <5190841E.9090503@canonical.com>
References: <CA+6wjbxdbTDXmO984sM1CHFT+PJJdvS=+YmwM2iu-10Ws4WouA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig02674164051A20ED5484CE37"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	hayeswang <hayeswang@realtek.com>
To: S L <sl4ever@gmail.com>, netdev <netdev@vger.kernel.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55675 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3EMGLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 02:11:54 -0400
In-Reply-To: <CA+6wjbxdbTDXmO984sM1CHFT+PJJdvS=+YmwM2iu-10Ws4WouA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig02674164051A20ED5484CE37
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12.05.2013 05:13, S L wrote:
> commit e5195c1f31f399289347e043d6abf3ffa80f0005 cause ssh KEXINIT failu=
re.
> the hardware is ASROCK B75 PRO3. dmesg show
>=20
> [    1.332961] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.333262] r8169 0000:03:00.0: irq 42 for MSI/MSI-X
> [    1.333414] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at
> 0xffffc90000024000, 11:11:11:11:11:11, XID 0c900800 IRQ 42
> [    1.333534] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 by=
tes,
> tx checksumming: ko]
>=20
> lspci -vn show
>=20
> 03:00.0 0200: 10ec:8168 (rev 06)
>         Subsystem: 1849:8168
>=20

That does not contain much detail information. Also its not too helpful t=
o send
such reports only to one person. I did not see ssh problems on my tests b=
ut that
could be a different configuration/environment.

-Stefan


--------------enig02674164051A20ED5484CE37
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRkIQmAAoJEOhnXe7L7s6jV3wQAMgQNL4MPBqQsHfVooR4b00Q
Eq2oq1+ZV+bB6/nEYH8YZl4TG4vA1+uVTYfLtadbyaUN5g4rTYkkgcN52UGkPZVU
IrgNgQzJ8RjD7zF5JldIU35xklbA39ieb+5imvGROiCNKC/xvsjHevHvr6FmwG+k
gGDVrTpy2X8G+JuEGDHIw5lMBo0IUXgODsdWq4fSo3tLYT20IQ34rjFpGv/VqYC2
ZlHykFWoU4Z/Bd9wuvhIO8tkzUZDLzaX8BcQcMVHnwG065yZBriMd4pxNb31+r2q
XD9mB3+rgXmXGRVNAMD2X38PiGVBHxu+ZeSZLZN0a6KZWFNSIv95zZEwBGOkD1j0
czlLJL6qXfIZNRTS/GictNO/Kc0zCaohRaYFyotmHylYF5PASWsnEM477oELxP7t
0l/tilblDlUWRvrjnUN1y/eobtGF1DNTXl58aQOk1gwwUm1MColPDxCtF78Ob2Ia
DSxTkK+Vey1KBQBBX4L9fNhvLZ6em2U7jfmDfblTjJGzox3sqsXQq7SoTkKctWle
QSVY15nkscifpuuZfS1bZH9+cUtA4v0BxFYNADnF+j/+hxVcWsUeAbha8fTb2+Fb
alMwJvgwop9ZjNQAukNDID6LTqWuaCOu5Wcjl3DCpKyryz3aXV5STsRQH7RqlF7z
XtzrPtTbDc6e3JFhUnyt
=5hBL
-----END PGP SIGNATURE-----

--------------enig02674164051A20ED5484CE37--
