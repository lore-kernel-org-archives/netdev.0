From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 02/14] ethernet: Use eth_<foo>_addr instead of
 memset
Date: Mon, 02 Mar 2015 20:09:34 -0800
Message-ID: <1425355774.2556.4.camel@jtkirshe-mobl>
References: <cover.1425354527.git.joe@perches.com>
	 <86d963752051ae24a93c9a26da1e847459723aed.1425354528.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-K9TTGXiSNeZvqIEF09ME"
Cc: netdev@vger.kernel.org, Don Fry <pcnet32@frontier.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borund
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <86d963752051ae24a93c9a26da1e847459723aed.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-K9TTGXiSNeZvqIEF09ME
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> Use the built-in function instead of memset.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
for the changes to Intel's ixgbe driver...

> ---
>  drivers/net/ethernet/amd/pcnet32.c                  | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 6 +++---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c   | 2 +-
>  drivers/net/ethernet/cisco/enic/enic_main.c         | 8 ++++----
>  drivers/net/ethernet/emulex/benet/be_cmds.c         | 2 +-
>  drivers/net/ethernet/emulex/benet/be_main.c         | 2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c      | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_selftest.c    | 2 +-
>  drivers/net/ethernet/micrel/ksz884x.c               | 2 +-
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c  | 2 +-
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c        | 2 +-
>  drivers/net/ethernet/smsc/smsc911x.c                | 2 +-
>  drivers/net/ethernet/ti/netcp_core.c                | 2 +-
>  drivers/net/ethernet/toshiba/ps3_gelic_wireless.c   | 4 ++--
>  drivers/net/ethernet/xscale/ixp4xx_eth.c            | 2 +-
>  17 files changed, 25 insertions(+), 25 deletions(-)
...
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/=
ethernet/intel/ixgbe/ixgbe_main.c
> index 70cc4c5..903664f 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -3924,7 +3924,7 @@ static void ixgbe_flush_sw_mac_table(struct ixgbe_a=
dapter *adapter)
>  	for (i =3D 0; i < hw->mac.num_rar_entries; i++) {
>  		adapter->mac_table[i].state |=3D IXGBE_MAC_STATE_MODIFIED;
>  		adapter->mac_table[i].state &=3D ~IXGBE_MAC_STATE_IN_USE;
> -		memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
> +		eth_zero_addr(adapter->mac_table[i].addr);
>  		adapter->mac_table[i].queue =3D 0;
>  	}
>  	ixgbe_sync_mac_table(adapter);
> @@ -3992,7 +3992,7 @@ int ixgbe_del_mac_filter(struct ixgbe_adapter *adap=
ter, u8 *addr, u16 queue)
>  		    adapter->mac_table[i].queue =3D=3D queue) {
>  			adapter->mac_table[i].state |=3D IXGBE_MAC_STATE_MODIFIED;
>  			adapter->mac_table[i].state &=3D ~IXGBE_MAC_STATE_IN_USE;
> -			memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
> +			eth_zero_addr(adapter->mac_table[i].addr);
>  			adapter->mac_table[i].queue =3D 0;
>  			ixgbe_sync_mac_table(adapter);
>  			return 0;


--=-K9TTGXiSNeZvqIEF09ME
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9TP+AAoJEOVv75VaS+3OsrMP/3j/26w6QxL90rivVZA1Kt2K
6exmDgxNVr5Ew6Iysx3bXuVpkpk5tBozoR6kJo5aJ2/07o1iQoN3RrClWxH7FUVX
VGo7mJBpBryquBJHbeOQBh1L0OF6SfaFPa+lZozgyMbv8DNXKsRVT0RQzHlMXtqT
k/vaNLIynnSc41zM8xElwG4KLUGCnvzmbBT6k+qHXJA+AKVM3bceISvjxKaDLjG1
JXDzZINJf+r0MshVzZ/4Qh7OcTcbdvEf0CYjHgCxLT0N2uKfVqPnimvxk+4Z7IIw
I/o4Zyan0fPZG1mb2ieKJ8hCMXsBfUDC+vSTKDrNfIkMBJU12ITc0Oc5sVA+jYFR
V0LA+vEZxHEnTXSAx8Dgba1t/zzWrNX/3HadRs/vv6ZNBVuS4897EBgnasfp1DCX
ZK9OQ8+k9X566Kl6nb4sCtHgZsObnnNs31ZDbwq4Zy9AYcYQZDoEanUnRZOCTnaL
YJSvEpBlGdDOCPc8L7Z6NiD2yYLrEuu1gtGf/yO/jW63G1fr2LA9m41e2QXokrHl
uKG54/p6Jqtx3KwQ68w1dWX9VOCXmkKlg0rSPq9r1Ui3WZ2k75Ww1WbEaOFbcX/L
mCvtf42JCeq+LPjwYrpF16ndBhp3Pw+pPXhS/e4dBTt+jYfxqniwoiyuy5e914Nl
wbyk5VXu4X1QgSbNONaf
=APcW
-----END PGP SIGNATURE-----

--=-K9TTGXiSNeZvqIEF09ME--
