From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Sat, 21 Jul 2012 10:37:48 -0700
Message-ID: <1342892268.2135.3.camel@jtkirshe-mobl>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i2CLFrMMhph6gHa/63mf"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16395 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab2GURhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 13:37:50 -0400
In-Reply-To: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i2CLFrMMhph6gHa/63mf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-07-20 at 14:43 -0700, Kirsher, Jeffrey T wrote:
> This series contains updates to ethtool, e1000, e1000e and igb with
> regards to the new MDI ethtool support patches submitted earlier.
>=20
> The following are changes since commit fa0afcd10951afad2022dda09777d2bf70=
cdab3d:
>   atl1c: fix issue of io access mode for AR8152 v2.1
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Bruce W Allan (1):
>   e1000e: implement 82577/579 MDI setting support
>=20
> Jesse Brandeburg (5):
>   ethtool.h: MDI setting support
>   igb: implement 580 MDI setting support
>   e1000: configure and read MDI settings
>   e1000e: implement MDI/MDI-X control
>   igb: update to allow reading/setting MDI state
>=20
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   34 ++++++++++++++++=
+++
>  drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 +++
>  drivers/net/ethernet/intel/e1000e/ethtool.c      |   39 ++++++++++++++++=
+++---
>  drivers/net/ethernet/intel/e1000e/phy.c          |   31 +++++++++++++++-=
-
>  drivers/net/ethernet/intel/igb/e1000_phy.c       |   29 ++++++++++++++--
>  drivers/net/ethernet/intel/igb/e1000_phy.h       |    5 +--
>  drivers/net/ethernet/intel/igb/igb_ethtool.c     |   37 ++++++++++++++++=
++++
>  drivers/net/ethernet/intel/igb/igb_main.c        |    4 +++
>  include/linux/ethtool.h                          |   17 ++++++----
>  9 files changed, 184 insertions(+), 16 deletions(-)
>=20
> --
> 1.7.10.4
>=20

Since there some changes that are needed in this patch set, I will drop
this series from my tree so that I can continue pushing additional
ixgbe/ixgbevf patches.

--=-i2CLFrMMhph6gHa/63mf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCujsAAoJEOVv75VaS+3O20QP/ibTmgI3EVXFXxJtctWL5mbK
VdR6TVfUZalkt8WXm27i+yTsaNmPKRxUhdNM/Lcg3HZteYbPWkEFic8yJb16FjiM
i221rAdCVNQDxb5WyfKqelWjcj0uc8F8u2tXyNKUmwCiwFeWTzhQb5Ti+P5ruoYa
gybiFbiTI0nVQqB7d/f3BqyxRLVlwdX4LnSkdc1SgTRmiBRg42fOB8/TlftI6IxA
0nxaIA7KeWSyfvvIpJcUzGZGeobzAJkG8zFDH7urXtvXhlFpoOlx1UaXZUA7+X1g
D4ODtbd0IRJDevKi1De/PcrX2qTkQVhCu+1+I4OL06Bw73vnxHGXWry5IgtW6w+B
A/ZuFep111XjQIhUCrSBVbYHtZ3T8b0Sq2S28/EhhoW0zD372gi0SlDOKOy+ezWl
EHIvncpzDaGL/6SkhBM7U644cHKEZ47hFWIOLIEsvdAiNoGcih1Z9QOR/YQeHTvX
j39Unpzd5cUeaQm5+smHD0OVFq5U4xY0pPBkXXl9X7b1FSCn69CIhgQwSSL7P/k6
kLF6pfUJPE9Y8Y+45tut0+cS/dXQnmuDdOWvjRCfK1GHGg0a8NmU6D25R3dArSEc
mychtl2LYQVQN4bq7OAR1+BbstTZJfajXZ6nOI+ZMZRLHSA4d+MBjPkcgAALMbZE
jtlLNLeY8f1hapCyU6iX
=UXTM
-----END PGP SIGNATURE-----

--=-i2CLFrMMhph6gHa/63mf--
