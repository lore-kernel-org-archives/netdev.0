From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 3 Nov 2015 17:51:42 +0100
Message-ID: <20151103175142.70320eef@wiggum>
References: <5928552.0ccybX7Zly@wuerfel>
	<20151103172721.04533081@wiggum>
	<7423389.1hNz9LlOCE@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/SBUqC/SweDQ.kvWOyBMeDEo"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-kernel@vger.kernel.org, zajec5@gmail.com,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7423389.1hNz9LlOCE@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/SBUqC/SweDQ.kvWOyBMeDEo
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Nov 2015 17:42:26 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 03 November 2015 17:27:21 Michael B=C3=BCsch wrote:
> > On Tue, 03 Nov 2015 16:05:51 +0100
> > Arnd Bergmann <arnd@arndb.de> wrote:
> >  =20
> > > The SoC variant of the ssb code is now optional like the other
> > > ones, which means we can build the framwork without any
> > > front-end, but that results in a warning:
> > >=20
> > > drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but no=
t used [-Wunused-function]
> > >=20
> > > This annotates the ssb_bus_register function as __maybe_unused to
> > > shut up the warning. A configuration like this will not work on
> > > any hardware of course, but we still want this to silently build
> > > without warnings if the configuration is allowed in the first
> > > place. =20
> >=20
> >=20
> > Is there a simple way to disallow this configuration? =20
>=20
> I could not come up with a simple one. We could turn 'CONFIG_SSB' into
> a silent option and have it selected by each bus specific driver,
> but then we also have to change all the device drivers (usb and
> wireless I guess) to use 'depends on' rather than 'select'.

The other way around?
The drivers already select SSB. However I think we should have SSB
selectable by user for the embedded case.

But well, I can live with this patch then. Kalle, you might apply it
with

Acked-by: Michael Buesch <m@bues.ch>

--=20
Michael

--Sig_/SBUqC/SweDQ.kvWOyBMeDEo
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWOOYeAAoJEPUyvh2QjYsONqUP/Rvbw5uHEePmKUwEWRjnAJx4
W61v8XBri9WgLLpVp/osDD5xxPb5/joyUZ/7NO+FQLX8jGUctzGd7YCOiWWv2/36
8nKe8cwFy2Y31im+m8b3J1e3/2r6TLppcZ/dSmY1WcV/BIyzi7dc0TnJAALVZgdf
5pN6H4BQFiPqSFq0V9fCFp9Q0dNrvPZfj3zC3a0K0QKwpzM6MhuTOxsnuFaXMkIV
smq3+G+lcFMN4cHa7+Zr5LGNBBuhpE4jzwPODB2SwSiT4W0pNvuZFRKfp5ha3s9G
aX6Gds1P645jbk4bsRRwiNX45dbrDqN3CvHyHMxbxdkmjokH8PZQrkskwoqbyPxU
cYGZdCtuf2t+bva1UVJr3hXAJpgeB+/1wQIVVzdurSplPxYZ5tmoHqLh8/yf7TjW
dTBPCRQf98W6bESFVgYldskkkkKpLWeiwMltmv+PXmPbR88WpA/IFT29Q0xnrmMs
lEEJ9bt+pqTNzgMaiLMDXxp1wGCVa555g+d+22DP7cGjgBctgKc8HTOyBc19JDVp
mGTANBbBX1VRUHNkIEW88knjnsSd1MOhpRnCSIcTEW2bypgVCQsJdWiR30i1oZXr
Y2wUjfXoJH7SzxtPfz+mQrxS90JAOZIoGRTD8A79r8bX3ISmRqL+44M+wHLqTC9C
Yxs+MGlPIv+TxfaVlTnc
=oAZD
-----END PGP SIGNATURE-----

--Sig_/SBUqC/SweDQ.kvWOyBMeDEo--
