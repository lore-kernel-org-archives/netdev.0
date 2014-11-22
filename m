From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] i40e: enable fdb add code, remove unused code
Date: Fri, 21 Nov 2014 21:53:44 -0800
Message-ID: <1416635624.2280.107.camel@jtkirshe-mobl>
References: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJ3xEMhRw=NLQOYAQ1X6UUm9nvpaJxcuVt_DTNiybAbDJG=qJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-e+RpG+mu5mQS66WR77kz"
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40581 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbaKVFxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:53:46 -0500
In-Reply-To: <CAJ3xEMhRw=NLQOYAQ1X6UUm9nvpaJxcuVt_DTNiybAbDJG=qJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e+RpG+mu5mQS66WR77kz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 06:50 +0200, Or Gerlitz wrote:
> On Fri, Nov 21, 2014 at 2:30 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
> > The fdb_add functionality is important to i40e because it is needed
> > for a workaround to allow bridges to work correctly on the i40e
> > hardware.
>=20
> Can you please shed more light on the precise problem and solution? I
> wonder if one or two of them are generic... so might can/need land
> somewhere upper...

This is not a generic problem, it is an errata related to source pruning
that can be worked around by adding VSI MAC addresses to the HW filters.

Information about it can be found in the driver readme.

--=-e+RpG+mu5mQS66WR77kz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUcCToAAoJEOVv75VaS+3ONpEP/RGLvFls9aHl2xE/mN7ejY3L
ZUXoMfE82RrjK0CGkze8xXhpZsvzh+9MdMsWvzlbvDHmxa7MohN2jiNB93enWuuk
Bs5TqYUOE4+5Yg8nkE1VUkwhYCvCQbr4C8ZU7cNZ4HVfEMtdyjPKDeuXYzzQ6zFI
/OFtwumCijeAkBuMmf8lunPC8kQb6AGGxItKKXSDskKrbwRsEqbM+9co/YxKoK96
BmrsFzRlT3Nd89C8Pe90czRkYJql/vtp1poi80B21CpjDWdZwqWonGeCMEwx+Wzw
pgLCkeqAUlLnY2VytHUX4ngp8kyYuGC7L/lWIZbeQPoE0Zj8dYeYd9VDQ4XBvyy5
OwL5E2aeiccrvmhBI+m4Cxg3cHkU19uA+zx1a7OHpjVhMO6bOOyOEWTTqY7SwHpl
V6SsDag5oSexKRt39L4ERZkulm0VSdYPDiQAvbbHa1Z0GzYuG8ABSp/W2uU1yNHJ
XKafiwb/OR65TiiQxKjZLO1JSFSrU6BBjoHTFI9E/GGSRItbnMCNkXNOT9I3DyVq
Jp7C2vealLMeRxyFJHKPq2qO3p1wS0mk1dHc1fGyNHHDpX0+J7vYkuL24Pzzk4f5
Xv3x4HLt+NcTtGBubylF97dYi86AYg7DzWVi+Qye97lIhR407M5Ti83s58sH+/zk
D3nOE9b71jD4mzpgb5lc
=7Qa4
-----END PGP SIGNATURE-----

--=-e+RpG+mu5mQS66WR77kz--
