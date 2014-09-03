From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 0/6] Simplify Intel Wired LAN driver init/exit
 routine
Date: Tue, 02 Sep 2014 22:17:40 -0700
Message-ID: <1409721460.2384.27.camel@jtkirshe-mobl>
References: <1409650616-1035-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ivLUAzYUC4mGvxf9SsKz"
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:28076 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817AbaICFRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 01:17:42 -0400
In-Reply-To: <1409650616-1035-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ivLUAzYUC4mGvxf9SsKz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-09-02 at 03:36 -0600, Jean Sacren wrote:
> This series uses module_pci_driver() to simplify the init/exit
> routine of some Intel Wired LAN drivers.
>=20
> Jean Sacren (6):
>   ixgb: remove the boilerplate of ixgb module for init/exit
>   ixgbevf: remove the boilerplate of ixgbevf module for init/exit
>   e100: remove the boilerplate of e100 module for init/exit
>   igbvf: remove the boilerplate of igbvf module for init/exit
>   e1000e: remove the boilerplate of e1000e module for init/exit
>   i40evf: remove the boilerplate of i40evf module for init/exit
>=20
>  drivers/net/ethernet/intel/e100.c                 | 22 ++++---------
>  drivers/net/ethernet/intel/e1000e/netdev.c        | 35 +++--------------=
---
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c   | 37 +++--------------=
----
>  drivers/net/ethernet/intel/igbvf/netdev.c         | 35 +++--------------=
---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c       | 39 +++--------------=
------
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 38 ++++-------------=
-----
>  6 files changed, 32 insertions(+), 174 deletions(-)
>=20

I have gone ahead and added this series to my queue.  We have some
concerns that these changes will make it more difficult to debug the
drivers, so I will have these go through our validation as well.

--=-ivLUAzYUC4mGvxf9SsKz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUBqR0AAoJEOVv75VaS+3OZQMP/1COvEl06rPRN48bSMydo1k2
VYu0JCwlWxar1GqJ7okr8m9cvJhGlmWuGOna8KpwER3HrdGot7XiltTDyNCMZ0G7
TMuFfvWiDSE3Zf7GIc6r5gEvg4e3UHoqP8sum/bRjbSJdu0moxjiV7YmYPQcHZFH
jjMAFyoUR83dAEfpoDrWz0XoDLYOxdNvO5nR0i6eYCqRydKwqZOS6I5r6vo3J5gL
yF61vmnpeyCeEYbXHh6AV1+/ouk+cCf+uVAdCtUgTJXFvSCGpZVos7sFL22D5oAs
42qE5vr2GmLfIRZIxQicLaW9I33jf+Norvf/+OV4YZGNGla61DFNHCW888Vcmwci
vozlsUqn7Uva1J1xmd1EQA9qoANmyTvNLJGnKyogZ/LjF6cI9wOkGUL8kMzQr0jN
6RKzO6CkIpz/U2CeeVBGsEDInLzeeLgfP0RD3f3+yyknAZmm6edqCavAWcKUP+kt
eD0sAQwq/mrYoFlBLV8Sw5BqnaslBeghwQbv6zPWWg5kG6yNlnA2pwc8VNv78Lae
jbtfMwO1HSM7IYqxZm65QdXf1Io8XCZL7FhtJt4IItxOvmxiTixxMFuDTp/srji6
++/GTjdpSn39OhT20KpdNLtrhcK94Zekt6U6nYZq+thliEQDcYkRJMeH7pnM0oGK
j2dYnlmDROYdI9wCRFO3
=ccjf
-----END PGP SIGNATURE-----

--=-ivLUAzYUC4mGvxf9SsKz--
