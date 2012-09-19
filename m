From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue, 18 Sep 2012 23:03:55 -0700
Message-ID: <1348034635.2006.52.camel@jtkirshe-mobl>
References: <1348029108-26659-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TT1wLLuJgN+En6W7hwB1"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30371 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157Ab2ISGD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 02:03:56 -0400
In-Reply-To: <1348029108-26659-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TT1wLLuJgN+En6W7hwB1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-09-18 at 21:31 -0700, Jeff Kirsher wrote:
> This series contains updates to igb and ixgbevf.
>=20
> The following are changes since commit adccff34de1ef81564b7e6c436f762e7a1=
caf807:
>   net/tipc/name_table.c: Remove unecessary semicolon
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Akeem G. Abodunrin (1):
>   igb: Support to enable EEE on all eee_supported devices
>=20
> Alexander Duyck (2):
>   igb: Remove artificial restriction on RQDPC stat reading
>   ixgbevf: Add support for VF API negotiation
>=20
> John Fastabend (1):
>   ixgbevf: scheduling while atomic in reset hw path
>=20
>  drivers/net/ethernet/intel/igb/e1000_82575.c      | 17 +++++++---
>  drivers/net/ethernet/intel/igb/e1000_defines.h    |  3 +-
>  drivers/net/ethernet/intel/igb/e1000_regs.h       |  1 +
>  drivers/net/ethernet/intel/igb/igb_main.c         |  8 +++--
>  drivers/net/ethernet/intel/ixgbevf/defines.h      |  1 +
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 23 +++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          | 21 ++++++++++--
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 39 +++++++++++++++++=
+++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  3 ++
>  9 files changed, 105 insertions(+), 11 deletions(-)
>=20

Dave,

Do not pull, it appears there will be changes to patch 04 of the series,
I will be sending a v2 of the series once John gets patch 04 fixed up.

Cheers,
Jeff

--=-TT1wLLuJgN+En6W7hwB1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQWWBLAAoJEOVv75VaS+3OJN0P/3ABPKu8Az5k1HG3JrcHQCMe
vLdBaBFVEp/KDurtYHYB3vSzc6UB3IRiu0Rus9DNRBZ+j/yFM7CPXpslNReuOWFu
XMPTDwHXrZOsFbvgaNxDt2cz29TCFEAYzXnuQQlB2PUO6c9tXTvlCcz7+FmA4r8Z
K6pZuslC2KhI2X5E3CJtzaiEC57AXo3TaHpjBnrrwAo0NwkbkkOKM2qpCApBHOKD
IAf5axEjPBD7dKwejG6vDx7L6LdgvNSp5IwQ1kICf0529pHM2A2wv+U04M5PMEZ/
7n1V2+9Els25V3HNN7mjPRmRtg1Xm14d+SkW6Kde46gsH+Nbyftr7XyNY7q+vJMP
NAD7HaIwMsDzMgW0OLYGVJK8cnpocFdlLG1y04ATq7hpiwClNrji5T6zZ07oe38E
5Ss2M83gXeBp6eYbPT8TUnv329Bz0uTmoBFH0xDyUQcnEGIGREJQyO97GxeVBGMe
nBTP2DtM03nmMvdibLfTwWI2tNJ0hkLu3Gzx1LzM2ZY+ftKZcS7p+K9ZX8Rtay6i
bm92tzJN1cP8TwqZp9yZcxSCBSQzmjVVMt34yHCQvEv4t3wDcWCGypsJwzUoI2oU
M8Pl3BEW1eayoiFN4ThIflvSV0BQ4wX06SH5CMbvK4OdDCIGRcMmuyDPzzxgXQrP
VGwjt6LDuKYmpzqtZTv3
=4Va7
-----END PGP SIGNATURE-----

--=-TT1wLLuJgN+En6W7hwB1--
