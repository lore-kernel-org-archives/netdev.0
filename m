From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Question about the drivers movement (IBM_NEW_EMAC)
Date: Thu, 11 Aug 2011 19:22:38 -0700
Message-ID: <1313115758.2057.25.camel@jtkirshe-mobl>
References: <20110812120744.1912ca01ab4e76faaa93892c@canb.auug.org.au>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-GuthjxeeG5onEOrCQUvS"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110812120744.1912ca01ab4e76faaa93892c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GuthjxeeG5onEOrCQUvS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 19:07 -0700, Stephen Rothwell wrote:
> Hi Jeff,
>=20
> In commit 9aa328359545 ("ehea/ibm*: Move the IBM drivers") from Dave's
> net tree, you not only move the drivers around, but you change
> CONFIG_IBM_NEW_EMAC to CONFIG_IBM_EMAC.  Won't that mean that all the
> PowerPC configs that currently set CONFIG_IBM_NEW_EMAC to y will no
> longer build this driver?
>=20

Your right.  The defconfig's will need to be updated by the arch
maintainers.  This particular change was requested by the maintainer's
of the driver.

--=-GuthjxeeG5onEOrCQUvS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJORI5uAAoJECTsCADr/EWU+lIH/2jbFn1/qICXEEhm0SnIINUl
K/2EVC5sJS2CN8lYouERhJymgRtX1dxeKBaqFVrQQQTV3oz80Xk/GmjbRjNCOhRS
CBB3M9fCyVByl+RCcrPfH3jUjlw5+Xs8r9DzZfnuz/qW4jkyU9qGuhFlo6gpTcDY
VvzPqKTy9LeCMyT+DOhWVcWNWf1kSZoHEXCvJxbp412x3+e+PXtEvWNqXNuAnO6R
hxa+zk+2366NRwg8mQGzW1bVQPQOCHDsoFIrlA20Yl12exr3IUh2BgF7bVIIhqX6
e5tiEkFMTfjSJ4eRXZkeBPE/8DZkoKRiclSCp+wjBzuivCJApQqvg1AHj6i/qo4=
=P9D0
-----END PGP SIGNATURE-----

--=-GuthjxeeG5onEOrCQUvS--
