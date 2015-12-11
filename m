From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 2/4] i40e: geneve tunnel offload support
Date: Thu, 10 Dec 2015 21:44:26 -0800
Message-ID: <1449812666.3194.94.camel@intel.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
	 <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BwG1M/VHZLsV3FOuCJlJ"
Cc: jeffrey.t.kirsher@intel.org, Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:45681 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbbLKFo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 00:44:28 -0500
In-Reply-To: <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BwG1M/VHZLsV3FOuCJlJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-12-08 at 10:12 -0800, Anjali Singhai Jain wrote:
> This patch adds driver hooks to implement ndo_ops to add/del
> udp port in the HW to identify GENEVE tunnels.
>=20
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 16 +--
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 167
> ++++++++++++++++++++++------
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.c |=C2=A0=C2=A0 8 +-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_txrx.h |=C2=A0=C2=A0 2 +-
> =C2=A04 files changed, 150 insertions(+), 43 deletions(-)

--=-BwG1M/VHZLsV3FOuCJlJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWamK6AAoJEOVv75VaS+3OVLMP/3ebmfZzJK3+56zefydC83aQ
dja2DpbGxjHLS+/tUGRZbLoutEjmBxCcxhIKJ5F9neayyq5ClkT8piKhwZIBgGhI
e9xDmXnYGKoe4OFcgBuG8s1QkzGXdkKJRvwGy9H9bBaLgWl4IJNrR044dkhgvP0U
qRX5ru436nBAsBQxkLhr8Hw1euIvHlDPeWYk25T3rVisTptKfPz9rxYoZBygdpWA
SsVZge3jV7Zz+KF4Ek7HMCYPuhjB55qi7gVTvhTo4iY21OiJTpD1gbXDmzJFxV61
uabIX3zkvc64TMPh/m/wbZII8kYWcyV7+ssuS9J4KKwbh/1CHhFTkYly1EC2WYXv
rXfeWu6mJGWR0FpIjt/eyxfW/bTSt4sdlLeHV10SO39ebZtAg5ijGR3M20bWoaWV
p8cIPuuOGghRwVLEMi4fVOb4Th8jz4zePfKYqlLlukQRn03MGo1JxvuCDXjJOsKN
yWT2TbnsTMqKqB1eVlDnowsddMgnDz1vAeTzSX0lvj6uec5QkC1ZnHuZtmzT+5ML
/w1aR+kLywICODA4Y7hHboB8iRPP2mWzMf51sN2DVqfFpsrfQ5tDp6+JNfoGwILT
fwetuiJ81SliZ7DGOuBCOIb5MsFS4E/oxEOcmyljNRjaewAyjc4+eQnTIBpl2Nv3
Ug+O2a6Cenw1tyDjlfEl
=U1Rp
-----END PGP SIGNATURE-----

--=-BwG1M/VHZLsV3FOuCJlJ--
