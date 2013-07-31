From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2 v2] igb: Expose RSS indirection table for ethtool
Date: Wed, 31 Jul 2013 05:13:22 -0700
Message-ID: <1375272802.2877.35.camel@jtkirshe-mobl>
References: <1375271273-20122-1-git-send-email-laura.vasilescu@rosedu.org>
	 <1375271273-20122-2-git-send-email-laura.vasilescu@rosedu.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VdN3aqHvjiO2/UCz7Nee"
Cc: netdev@vger.kernel.org, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com, alexander.h.duyck@intel.com
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47841 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288Ab3GaMNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 08:13:32 -0400
In-Reply-To: <1375271273-20122-2-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VdN3aqHvjiO2/UCz7Nee
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-07-31 at 14:47 +0300, Laura Mihaela Vasilescu wrote:
> This patch adds the ethtool callbacks necessary to change the RETA
> indirection table from userspace.
>=20
> In order to achieve this, we add the indirection table field
> (rss_indir_tbl)
> in the board specific data structure (struct igb_adapter) to preserve
> the
> values across hardware resets.
>=20
> The indirection table must be initialized with default values in the
> following cases:
>         * at module init time
>         * when the number of RX queues changes.
> For this reason we add a new field (rss_indir_tbl_init) in igb_adapter
> that keeps track of the number of RX queues. Whenever the number of RX
> queues changes, the rss_indir_tbl is modified and initialized with
> default
> values. The rss_indir_tbl_init is updated accordingly.
>=20
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> ---
> Changes since v1:
>         * enhance commit description
>=20
>  drivers/net/ethernet/intel/igb/igb.h         |    3 +
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   87
> ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igb/igb_main.c    |   28 +++------
>  3 files changed, 97 insertions(+), 21 deletions(-)=20

Added to my queue, thanks again Laura!

--=-VdN3aqHvjiO2/UCz7Nee
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR+P9iAAoJEOVv75VaS+3Otm0P/2WnjgyM7hKdwSc7x6GkwO+E
qvY/O5kehjvMoaF7ZxcTH7IaMULulAQZ8HEvH75Re1/ZVcd0N0d98uEUx1ol/05S
lC3a42p07LwrZwGcsZXcbgmd3Wqjfjl/AmO3hZuTSdaYGaODjWjgV8B2qMbWimCA
NCVH6OZebnq/mz25IhON2hOZ7JOSnQfDkYHCcPpylQ5pMVql8bJRMPuFJn1gDU7/
oEyB6opFJdtob3KiPWNHcrgqSqSIwTDXYqTpyni5aU9Z+yTWh7TtKN86Y1LTiNRd
Jcq/l7cfPy1q+ZMDn8U4tzwBq5HkxLr1Y6N27EklFoGTMvxw3YiAJyq1PGpWsOj7
G0bpm+eUBoSFbtUf9Ay71fr5ogYeSjgzkpB2LqcF1EdjpvIOGcciyomK4Pp8qaTz
Rv2YCwD8BTkpe05t+H+osu9zciZco7PiX7KQtuhn7MwH/JfZxst5T2/KUQqtf4Zx
iaFWJyvPHSsPyUkx/ynvc8zsdRLSsJPe3zzVkW/G12GtmsduUSbBBb/Bk2DcxcpU
pLdNiZsbrSSwmbDu8/B3zT/DEVeMuGOvW77g88RMHMjk+JiaqbLUiSJl3xPQ213x
M+XNUHg9L+vxoXwJT0v6xWzBGMQooh6SQvp1zbSDT8jnL1jUkEqK3C+7+gv9Kz0x
vRA3dhqiigN/R4KCP7mI
=f+7v
-----END PGP SIGNATURE-----

--=-VdN3aqHvjiO2/UCz7Nee--
