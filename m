From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/11 v2][pull request] Intel Wired LAN Driver Updates
Date: Fri, 30 Sep 2011 21:56:15 -0700
Message-ID: <1317444986.2562.1.camel@jtkirshe-mobl>
References: <1317444771-13962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-x9Eh9ZstXl6/UG5Voztw"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21899 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab1JAE40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Oct 2011 00:56:26 -0400
In-Reply-To: <1317444771-13962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-x9Eh9ZstXl6/UG5Voztw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-30 at 21:52 -0700, Kirsher, Jeffrey T wrote:
> The following series contains updates to e1000e and ixgbe. The one
> patch for e1000e makes function tables const, thanks to Stephen
> Hemminger for reporting this.  The remaining patches are for ixgbe,
> and the contain the following:
>=20
>  - minor cleanups
>  - add support for 82599 device and ethtool -E support
>  - removal of a PHY which is not used in production silicon
>=20
> v2- Updated patch 11 with the suggested changes from Ben Hutchings
>=20
> The following are changes since commit 56fd49e399ce1d82200fad5b8924d4e35a=
587809:
>   bna: Driver Version changed to 3.0.2.2
> and are available in the git repository at
>   git://github.com/Jkirsher/net-next.git
>=20
> Emil Tantilov (8):
>   ixgbe: prevent link checks while resetting
>   ixgbe: clear the data field in ixgbe_read_i2c_byte_generic
>   ixgbe: remove return code for functions that always return 0
>   ixgbe: add support for new 82599 device
>   ixgbe: send MFLCN to ethtool
>   ixgbe: do not disable flow control in ixgbe_check_mac_link
>   ixgbe: remove instances of ixgbe_phy_aq for 82598 and 82599
>   ixgbe: allow eeprom writes via ethtool
>=20
> Jacob Keller (1):
>   ixgbe: fix driver version initialization in firmware
>=20
> Jeff Kirsher (1):
>   e1000e: make function tables const
>=20
> Mika Lansirinne (1):
>   ixgbe: get pauseparam autoneg
>=20
>  drivers/net/ethernet/intel/e1000e/80003es2lan.c  |    8 +-
>  drivers/net/ethernet/intel/e1000e/82571.c        |   20 +++---
>  drivers/net/ethernet/intel/e1000e/e1000.h        |   28 ++++----
>  drivers/net/ethernet/intel/e1000e/ich8lan.c      |   16 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    8 +--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |    7 +--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |    6 --
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   74 ++++++++++++++++=
+++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   12 +++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   33 +++-------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |    1 +
>  12 files changed, 125 insertions(+), 89 deletions(-)
>=20

I did not re-send patches 1-10 of the series since there was no change.
I can re-send if necessary...

--=-x9Eh9ZstXl6/UG5Voztw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOhp1vAAoJECTsCADr/EWUkpQH/0PvqgZgd4RR5wnmsYp5KLLf
kdEzam1C1iKu17KnHVLbSHzZp9cihht7uzE7+zhnzan4QORspQDN0Nk6FU4r6ztF
vTwFuErkj4pPqzb65Kx6H5rlNT8MoJViqFou2nWEeYNwlfTd9weku2YaIY3gKoZa
bZCskvfc6mrkFvEK8d5O5uE9pOABo3hdi7axbwjVmfQgBKGrqpcnnQKVweDRgnIS
BKueYePLptv851RbnygUrYJYQ746XxSlOJRjyhmqMEPetxp+8dKF5WRhELF4OWBS
ZBBoLI6D0CE1fuZPyP857V4SI71T9x1WyijBJ0APCxpbi30xh5A4ph6y728UIDU=
=ZQ1r
-----END PGP SIGNATURE-----

--=-x9Eh9ZstXl6/UG5Voztw--
