From: Stefan Lippers-Hollmann <s.l-h@gmx.de>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Fri, 22 Jul 2016 04:39:22 +0200
Message-ID: <20160722043922.0a878698@mir>
References: <20160719153403.2967812-1-arnd@arndb.de>
	<3876342.AU5AfU16PB@wuerfel>
	<wrfjk2ggpbmw.fsf@redhat.com>
	<8046944.AyQGVaNKWH@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/L85adD7xhDL_cl8UJmadEcc"; protocol="application/pgp-signature"
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58045 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbcGVCjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 22:39:45 -0400
In-Reply-To: <8046944.AyQGVaNKWH@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/L85adD7xhDL_cl8UJmadEcc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi

On 2016-07-20, Arnd Bergmann wrote:
> On Wednesday, July 20, 2016 11:33:43 AM CEST Jes Sorensen wrote:
> > Arnd Bergmann <arnd@arndb.de> writes: =20
> > > On Wednesday, July 20, 2016 7:25:19 AM CEST Jes Sorensen wrote: =20
> > >> Arnd Bergmann <arnd@arndb.de> writes:
[...]
> Yes, I was just agreeing here that it's not worth doing that one.
> As far as I can see, the evolution of these devices is
>=20
> RTL81xxU (2008)
> RTL81xxSU (2009)
> RTL81xxCU (2010)

There is also RTL81xxDU, apparently from 2011, a dualband device
coming in several variants (single MAC + single PHY, double MAC +
double PHY and double PHY); e.g. 0bda:8194 (single PHY + single MAC).

While probably not overly common, it was/ is (hardware-wise) a pretty
interesting device due to its support for 5 GHz[1] - actually I hoped
it to be a (supported-) RTL8192CU variant when I bought it.=20
Unfortunately no driver[2] made it to staging or the proper kernel.

> RTL81xxEU (2013)

Regards
	Stefan Lippers-Hollmann

[1]	apparently even concurrent operations for the double MAC +=20
	double PHY variants
[2]	https://github.com/lwfinger/rtl8192du

--Sig_/L85adD7xhDL_cl8UJmadEcc
Content-Type: application/pgp-signature
Content-Description: Digitale Signatur von OpenPGP

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkYdaAAoJEL/gLWWx0ULtJOAQALth9Ql/gy3Uokmf+DoVE5r0
Dic6z2BA5lXA3yBGJ2y0CJePEvEJtQHkPON6iAmzw7YCVKbt20/p3KlYvGgdxvAb
7CWgAvt9GzYEtx5hKg9W8ysY7bLakkYTgCA482yQFXEVxuemjg1M6p5xF8saJSaQ
eopJu4pjGD/Zo1LA2qREx2qcPZrxCudnoWLpKMz0f5BVMBuTlJY2c6xehDKf7NJI
XHicnrs2OpiHq9OC8I+pLjaaylZ4HRG24Y1n4sPEQG2z7UT7E0fIH3EXFZalVXKt
TTP8LjT2p82iUevKUvV3X+xxF5BUWNlxRIIHJUB9CBgxGgRwEvS2bQc4NOyfn+no
4Z74amAt0GG9/oIlIb5pnLr9QMRGxV7eVYmgodjZtzrppYS3Xe87KYg+AgPOGUxh
N2+Znf9fjpcxcZ4m+3pwpu5h6Lk3yvzLtQg8SF0M/zKxSPaAh2gO1BFfjsY+Mi1i
ZUEexeBHRgcN4MCAfb6Y3YMzkv+E/pLnp7SwOx7NdjiHuZ0rqnsSx2IBwCr331oM
S9TPqFZL+Y3WicxLNftE1EBAFTsRqOmhglU1NiI6wxBHlWNBD0c7Zt+JfJm0OtGs
N5VF6nQOdxiPDRdJIEaWKLm1tAYckqf0G8fgrKNqxQv6Yt++8rK3Wvt99002CiPC
PZKGszcGQXsJaZMtoTlK
=4sxX
-----END PGP SIGNATURE-----

--Sig_/L85adD7xhDL_cl8UJmadEcc--
