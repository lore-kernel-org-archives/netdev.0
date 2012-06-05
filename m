From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Wed, 06 Jun 2012 00:30:05 +0100
Message-ID: <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
References: <20120605192820.GC7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hfaMZmiKemOhZmcg3Z9Z"
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53837 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753514Ab2FEXaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 19:30:19 -0400
In-Reply-To: <20120605192820.GC7683@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hfaMZmiKemOhZmcg3Z9Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-05 at 15:28 -0400, Josh Boyer wrote:
> Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) added use of
> the clk driver API which results in compile errors on architectures that
> don't implement the clk API.
>=20
> ERROR: "clk_enable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefin=
ed!
> ERROR: "clk_disable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefi=
ned!
> ERROR: "clk_put" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
> ERROR: "clk_get_rate" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undef=
ined!
> ERROR: "clk_get" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
>=20
> Selecting CLKDEV_LOOKUP doesn't fix this either, as the build then fails =
with:
>=20
> In file included from drivers/clk/clkdev.c:21:0:
> include/linux/clkdev.h:15:24: fatal error: asm/clkdev.h: No such file or =
directory
>=20
> So we just prevent this from building at all on PPC32.
[...]

This dependency was introduced by:

commit 16b817579fb61050f1abcc0e81089974328a9c27
Author: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date:   Sat Apr 16 15:24:30 2005 -0700

    [PATCH] ppc32: MV643XX ethernet is an option for Pegasos

commit 06ede91017d015a03cf8c1c87b3ff668f9a846e0
Author: Dale Farnsworth <dale@farnsworth.org>
Date:   Wed Sep 20 12:24:34 2006 -0700

    [PATCH] mv643xx_eth: restrict to 32-bit PPC_MULTIPLATFORM

If Pegasos is still supposed to be supported then this needs to be fixed
properly.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-hfaMZmiKemOhZmcg3Z9Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT86Wfee/yOyVhhEJAQoL8RAApPYHn4Pi5fTz7eNETnXYx88OcbOyu7eV
sqsXHnvRv3D7Q1jzims2X9d+lx1BDlR2MvpP0dnhjEKNTzf3NrY2eAedW/me6hvw
6krvxy2hyTcz3R0Dnl84vLkC7oYkvkQC04bRXayVWtpII9a9ExzeTBlHCMmDcOp3
sKRoZMDlnaWc3p57t/TktSfBomFyZtI4wamWzK7XrkqzkE6fj8BldZCqntjHDfVU
HhHCRg4F9s+F3RGvrCnGV3ROz/6sbW+fMPYLvFB31OnWzdIfi6FqVxMKClYJCGL7
O4TmABS5Bakn2+6QN27EUYcVoSPWyStiFA9TUb0scs0lgfTtTkSa4DhS1uTQRxRE
ihpOeXq/JY1EmIhtGyDrNgzgnHPGc34+J1ZApHE/GwvHoqd3IamSYY1OnWV6rvDN
UFaNXpwpA4JsTQrGZeMxw7b9uehZ24DiOXvA4S16vlVYbmy2Pai+OZ3khuDEzNPu
7jN6o/FYlIgBtoDyvJ6K3yFAlgKTy1r7bMqrBiKh6TyEiftVr3OFNLVzA3xNuuzg
GPFLZEQpguSzBWu/YVyFIj9yLSe1Y9DcjsAdMqc3P4trXMAYNibaPn2iVbcikM5C
r190ffNh2hzfxbInYwfw6194voK71lPW5X/3Gtuj6iCqo5rinoLX/y6xwTXTu5p5
JMbGc12JTYQ=
=ULU1
-----END PGP SIGNATURE-----

--=-hfaMZmiKemOhZmcg3Z9Z--
