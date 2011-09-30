From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 30 Sep 2011 11:35:01 -0700
Message-ID: <1317407701.2163.4.camel@jtkirshe-mobl>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-e/wYyxg6ZnTFJXaklelp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42275 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057Ab1I3SfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 14:35:02 -0400
In-Reply-To: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e/wYyxg6ZnTFJXaklelp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-09-29 at 22:24 -0700, Kirsher, Jeffrey T wrote:
> The following series contains updates to e1000e and ixgbe. The one
> patch for e1000e makes function tables const, thanks to Stephen
> Hemminger for reporting this.  The remaining patches are for ixgbe,
> and the contain the following:
>=20
>  - minor cleanups
>  - add support for 82599 device and ethtool -E support
>  - removal of a PHY which is not used in production silicon
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

Currently there is only 1 small change that needs to be made to patch 11
of the series, based on Ben's comments.

I will wait a bit longer before fixing up patch 11, to ensure that there
are no other changes needed.

--=-e/wYyxg6ZnTFJXaklelp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOhgvVAAoJECTsCADr/EWUx0QH/iKadWFTPehJObNQxnMRAfYu
5M5NF3mZeyclL8EgmtD1MPKCnGgBEqgnxBiLli8GZiGPZ50cb0fjmkJzYsfXZSr8
fEh1L0DB1PJyZTdEVB42Bqt59mGF/lglKLjEdgkQbwK6JPYFTYFWY8cdTx050wXh
nJYPqVFuAGxnGJ5CBZdD8DUbykfybpsFNuyMnjJTeDl2klR3gU2Xzm2U1MsrW+Gg
B3FPwiUges1AlrL2NHZ/2a0S5hQ+TYrreQP2Qc8LOoAAo3WpEUW/jMyMhlYo2And
v5WS5m04X3f/N50AVKEiYykBrJ9i21Gv5kOnBhibbuDt/dgID71BZLojgjgXIkM=
=tdu9
-----END PGP SIGNATURE-----

--=-e/wYyxg6ZnTFJXaklelp--
