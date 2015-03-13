From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Fri, 13 Mar 2015 13:48:47 +0000
Message-ID: <1426254527.4173.98.camel@decadent.org.uk>
References: <390621425930628@web28o.yandex.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AGYVU1ywE5MSDrq7OmhN"
Cc: Nimrod Andy <b38611@freescale.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9F=D0=B0=D0=BD=D0=BE=D0=B2_=D0=90=D0=BD=D0=B4=D1=80?=
	 =?UTF-8?Q?=D0=B5=D0=B9?= <rockford@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49216 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751378AbbCMNs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:48:57 -0400
In-Reply-To: <390621425930628@web28o.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AGYVU1ywE5MSDrq7OmhN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-09 at 22:50 +0300, =D0=9F=D0=B0=D0=BD=D0=BE=D0=B2 =D0=90=D0=
=BD=D0=B4=D1=80=D0=B5=D0=B9 wrote:
> Hello!
>=20
> Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introduces a=
 nasty bug in transmit, corrupting packets.
>=20
> To reproduce:
>=20
> $ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
> $ md5sum -b zeros
> 8f4e33f3dc3e414ff94e5fb6905cba8c *zeros
>=20
> This checksum is correct.
>=20
> Copy file "zeros" to another host with NFS, and it gets corrupted, checks=
um is changed.
> File should be big, small amounts of transmit isn't affected.
>=20
> I use an i.MX6 Quad board.
>=20
> If this commit is reverted, all works fine.

And the bug described in the commit message doesn't seem to exist in the
previous version.  The change just doesn't make sense to me.

I seem to remember DMA debug checks sometimes causing false positives
for network I/O, too.

Ben.

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-AGYVU1ywE5MSDrq7OmhN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQLqv+e/yOyVhhEJAQoufRAAxeCMmtkZc3X+lkd/22IFVOM/Jnrmx6Jj
diW41scrWwlOC+Apg/rGhrZqtuYHWwiG0i4I91j4KltD2euL2mwk3pu6y9GJvzwn
G+ccY/hik23pheD/fkFBuMHNHRC9x9fuwSI64bIBB+qGSCK1jx0d7uoQcDqx+YEt
KJr5+4P+43VMRvsq/X7re+nLtf9vOaZDW2UFT3KYFWCoWvmAOtzldfbEszBIATu+
n0UZFNK9tCrqnCXufnMLQziNRWgFpz3w0hwm4MxNlHIDibCopPZM1Eeh30GKUb5l
Fg8X+07eaV9c8s5ats784frzohd5MmuR3/lnZ42EqpbY/EBT2VwpQy7T8tW07l4U
X8TbdACcJU9KbEREWpf5WO/wpvFasw3yPM69ziFkh7ec9VYAd1sDO9l3iBg+WYVM
nB/U5NCeEsjjKcD/PgOjirdQ35ylaZH23OYb2e1IVr4l9HeV/zYLe7jR9Lpo4PVm
pFoEUg5Otwt30qqZFYfvSBd9Nu0Hh4BUy4vICQ5eASU684chapdniCCgT/yBTqkc
Tt/f6z9JeTNIjd/+0xopc3lwMkIA5ZbetZh2GVcEOW+K/q7cLjlOtQJYC3XRJgtf
DH7KocQJSxbZB4yL3hxQe31Au1lp0Dg8M+zNiKojk+NaMJstVKCwt4WA2CL5GXXi
1WnlUEep9u8=
=LCwZ
-----END PGP SIGNATURE-----

--=-AGYVU1ywE5MSDrq7OmhN--
