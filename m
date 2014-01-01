From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: cleanups
Date: Tue, 31 Dec 2013 16:59:16 -0800
Message-ID: <1388537956.26537.8.camel@jtkirshe-mobl>
References: <20131230103648.5ac53b4f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Dnfbz2qcwWnRKDSnjE3Z"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3671 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962AbaAAA7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Dec 2013 19:59:17 -0500
In-Reply-To: <20131230103648.5ac53b4f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Dnfbz2qcwWnRKDSnjE3Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-12-30 at 10:36 -0800, Stephen Hemminger wrote:
> This patch is against current version in net-next, some of this may
> not
> apply after other patches you have pending.
>=20
> Make local functions static.
>=20
> Delete unused code (igb_get_eee_status_i354,
> e1000_write_sfp_data_byte)
>=20
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>=20
>=20
>=20
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c |   37 --------------
>  drivers/net/ethernet/intel/igb/e1000_82575.h |    2=20
>  drivers/net/ethernet/intel/igb/e1000_i210.c  |   20 ++++---
>  drivers/net/ethernet/intel/igb/e1000_i210.h  |    9 ---
>  drivers/net/ethernet/intel/igb/e1000_phy.c   |   71
> ---------------------------
>  drivers/net/ethernet/intel/igb/e1000_phy.h   |    1=20
>  drivers/net/ethernet/intel/igb/igb.h         |    2=20
>  drivers/net/ethernet/intel/igb/igb_ptp.c     |    6 +-
>  8 files changed, 17 insertions(+), 131 deletions(-)

Thanks Stephen, I believe Carolyn already has a patch in the queue to
resolve all these, but just in case I add your patch to make sure that
all these get resolved or addressed.

--=-Dnfbz2qcwWnRKDSnjE3Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJSw2hkAAoJEOVv75VaS+3OaCsP/2GKHa/he34vyvRZKtvGrAS5
yLlXlPl94aVFHc37D1FEamE5pSi7klcUa50CkjZWbQ7LUnEHU5LUOR+9UFQ7npy3
Ya7LUwAkFmYCDJ2v5OOajgks8555iY4QLTFM7UgrSYBcX7z/aknVq2zZVUPU4uzg
50mon+m/dd7mFvdJR5jlpG52LEHK1mKIALG+cof+Jvorpc2t7PUmI/i3CaxzXmun
zlgneUBpL9D5cXhBtVVtnEQ1o3bC5tnmLYgkNBQF7OZEOoBFYG47cj6rdTn1nCtw
pY4991kB0oa+yVrJ8+Dg3rqn7NPKBXTlhYefskqUDp2fk4YTwRzvDjyPkBEJfSy1
4DhAPxtELmJVOXtJXqIkuyf9UAEk6+h3XtcWtbzBq4ZzzVNW6VU4IW945L8IwXT5
MXB1WbpZbOZi2+06r9qNHX3zN5fu0RuPG4EPbB3B2aA0MoXkp/12lBxRDNCu7TgV
k36cSrO4TceZfNAc9mgmVNlkYK2cpCdSScwct3swLTUW4mJZHhyiHpHRBRnE7/8q
6/g09b+6s8fuDJflY7cMkjjMGVBHT5yceRCdnFLELJCOWF4uw7l1e04Se0l/11NY
XA++YB4qSfyCO5Msk5PWm9PFBxfznIesv8ptTTUhXRu4TmlfATAd6R19dV1/yzLt
FDnBporF7ZLpfmeg9xo/
=Mt0F
-----END PGP SIGNATURE-----

--=-Dnfbz2qcwWnRKDSnjE3Z--
