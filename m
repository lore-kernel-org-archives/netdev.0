From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] add one parameter wro_enable to enable relaxed ordering
 for IXGBE
Date: Sat, 29 Oct 2016 00:42:21 -0700
Message-ID: <1477726941.2309.9.camel@intel.com>
References: <1477724932-5440-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-xfRoRUa23YDm6gMpY5g8"
To: Mao Wenan <maowenan@huawei.com>, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477724932-5440-1-git-send-email-maowenan@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xfRoRUa23YDm6gMpY5g8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-10-29 at 15:08 +0800, Mao Wenan wrote:
> This patch provides a way to enable relaxed ordering, where it helps with
> performance in some architecture.
> The default value of wro_enable is 0, if you want to enable relaxed
> ordering, please set wro_enable=3D1.
>=20
> Mao Wenan (1):
> =C2=A0 add one parameter wro_enable for IXGBE
>=20
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 |=C2=A0 1 +
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c=C2=A0 | 29 +++++++++=
+++++-----
> ------
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 28 +++++++++++++-=
---
> -------
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c=C2=A0=C2=A0 |=C2=A0 9=
 ++++++++
> =C2=A04 files changed, 41 insertions(+), 26 deletions(-)

Why have a title patch for only one patch? =C2=A0Better yet, the one patch =
does
not have a patch description. =C2=A0Get rid of the title patch and add the =
above
information into the patches description.

In addition, module parameters are not kindly looked upon, one reason is
that it cannot be standardized and enforced.

I am also confused because you are stating that on some architectures, yet
this code is only compiled in when SPARC is defined and that there are
times when you want relaxed ordering enabled and other times disabled?
=C2=A0Your gonna have to provide more data on why, because the code as is w=
as
resolving serious performance issues on SPARC when relaxed ordering was
enabled.
--=-xfRoRUa23YDm6gMpY5g8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYFFLeAAoJEOVv75VaS+3OnOQQAJKjXO0N/qoEb3F/eBhLvAwX
GsXRH2RhxQxdNSjjmlUhKQ4UUSw0+Ot1A+tuyLD5FfsDZYMqEHgzabMibNjKfsSQ
tm6Xk/X/BR80l092n67QKejGDtovLUGgRIKduSed4NkAHGGFW+v4dISo0BUik2xW
hhz3q7ILsj+kAd/e+s/lpsK/eJi4MxPI8W2BwXlSxMwyv9GR4pdxXXuY0U+tv4mh
a9+jfaUDH8x8TwcsQAr61VSjznjeNcatx1K1VwmDcYCK3HUMcHvM//TPbu9fWjZQ
4QUnFR7TnMjZFLkvzDIVastLd1wPzFXNLb7/agbtk2G9VfmS1G1DvMErD95719dy
4hcFQyEZwT46ioYl5lvMtMCUlXHvEOURCMgayX73KkhXW/dtyME4LokL9SmKZ68Z
SfDwWBPfqWUzuv6PcdyF7bRPqiCXMgIhMRE2ZxwUbMabu7rG8mhOxi9sX1xJ2ckH
zyAN0oIDcOye6JElo8D/HGsEhgR/9CF06O6rLclgeEApCYM+VFuW9MSc7r0zn5wT
uLuVAnVNT1kEjrnjwL23NUeEHeOUuYocvQLI4xs5G8e0QGwLD1jC/4G9voqfaB8p
M07lD+dvrUfHLJblmp2rC1yYm2Cx1RwVFF8h0Ttlpy8daOUdNuWT0BYhPDfRk6BN
VjCfKe00FrcCfPFFq630
=c6s6
-----END PGP SIGNATURE-----

--=-xfRoRUa23YDm6gMpY5g8--
