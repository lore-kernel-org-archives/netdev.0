From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v6 1/3] if_link: Add control trust VF
Date: Wed, 17 Jun 2015 05:23:42 -0700
Message-ID: <1434543822.3530.63.camel@intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE188B@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Wm20xcS82nJtBieB/22K"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12209 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519AbbFQMYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:24:13 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE188B@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Wm20xcS82nJtBieB/22K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-06-17 at 11:41 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Add netlink directives and ndo entry to trust VF user.
>=20
> This controls the special permission of VF user.
> The administrator will dedicatedly trust VF user to use some features
> which impacts security and/or performance.
>=20
> The administrator never turn it on unless VF user is fully trusted.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
> include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 19 +++++++++++++++++--
>  4 files changed, 27 insertions(+), 2 deletions(-)

Thanks Hiroshi, if there are no comments for change, I will get this
series applied to my next-queue for testing.

--=-Wm20xcS82nJtBieB/22K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVgWbOAAoJEOVv75VaS+3OXYEP/2naf1W4PTahTOAUa1wt/l5p
JW6e3BN8U0yLFGY8u/IBLEhvXEiQyuJLqZle50Irlei9V7sVYqs/88wFaeyVTWeo
q8f/4T2oci3S2OhZ3Ys4arHhGXUOoW/u5I5smzhDtLYP1y9Rx6En+mAxUXJOUDtS
K7a8LfLfPgifjtQkNDmvBw6rHWweo/ERRt2fP6t2vEiCnirxNMnY9xTvMa960gPF
4c72VkKSnW+UiKzWD8ea0DvRGFmPFChLjklX/qQIxVkIj6LPOHN++hjxGddTLMnY
ZJzfOmWJAWQDHf4A33sn9Ofbi8WnagTOVuHeWna8brIuXeTJxIGZzXrFZ+ShP0bF
zK5Hnr36g7YP7+9X3SqMN/5u89jk4g89jDaSbf7GAmtv4mlirmcKbs9q+J0HgJXd
F3f+ywrvdoHWOVj66FF0Kx/IHHFJG7xZwAsfjm5MDT5TjNEvzKG/QGXIbhREDcKc
5fnwQnKVZH6vyadjEu4QbTUsKlS+Nj3UQ4rSfTMwx+txtROJM5ryxa/mYmI8jSr4
rAc2Y6R+XwMrtqBbKtgYbIONxk2uuMF55O8iS1yKhzOqz89VuOI9wuRMTuBH9i4q
++mLY5Fgf5aZoXCyy75cAnAFD7RI9BhUT/btsb24sa4vpzYk5qesbHN00pTF+4ZM
slxiNWImVc8GC/0d7Sbj
=PPDh
-----END PGP SIGNATURE-----

--=-Wm20xcS82nJtBieB/22K--
