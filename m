From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: fix sparse warning
Date: Wed, 23 Feb 2011 16:03:40 -0800
Message-ID: <1298505820.25453.18.camel@jtkirshe-linux>
References: <20110223101203.0894c474@nehalam>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3JYI65itoBdnBwb+5bw+"
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30908 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042Ab1BXADk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 19:03:40 -0500
In-Reply-To: <20110223101203.0894c474@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3JYI65itoBdnBwb+5bw+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-02-23 at 10:12 -0800, Stephen Hemminger wrote:
> Sparse complains because the e1000 driver is calling ioread on a
> pointer
> not tagged as __iomem.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>=20

Thanks Stephen!  I have added this patch to my queue of e1000 patches.

--=-3JYI65itoBdnBwb+5bw+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNZaBcAAoJECTsCADr/EWUQEsH/AtcQtiAap23gc+Qk8jHWqTW
0RH83G2GwU1eBWHGH5ekw+275GZw4j0wd0Lo7XiHryxoemhudi7qAlasCpPH9o4a
axSBi12aognXsj6Ze4QothmKjuNgbnoqILXFpItCWI1WetMuGpgo9moEAzHwAUpv
4bRZJBFUm3Adbi+jY+ZPj9adFB79jBs2lwXk04Y232LY2CmVv4hu2UNU+qnI4ZWP
RYNl8yMgB2jXT921XHz/VyhN/ffyfoDqfyozWO5s9zXWix6TTFznB4QDl1/db62Q
u/AiGYx6Bj5keT8rLKBgyRPBtgri6h7RHYbqSkPJE7oKF712lo5GO7OzjOfJK2o=
=NosC
-----END PGP SIGNATURE-----

--=-3JYI65itoBdnBwb+5bw+--

