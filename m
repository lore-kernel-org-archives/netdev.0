From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] drivers/net: Remove boolean comparisons to
 true/false
Date: Thu, 09 Feb 2012 13:28:55 -0800
Message-ID: <1328822935.2242.1.camel@jtkirshe-mobl>
References: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
	 <20120209.133413.349832435589531136.davem@davemloft.net>
	 <1328822243.29329.11.camel@joe2Laptop>
Reply-To: jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-E23QgpvExXo1mIU6Vupx"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328822243.29329.11.camel@joe2Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-E23QgpvExXo1mIU6Vupx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-09 at 13:17 -0800, Joe Perches wrote:
> Booleans should not be compared to true or false
> but be directly tested or tested with !.
>=20
> Done via cocci script:
>=20
> @@
> bool t;
> @@
> - t =3D=3D true
> + t
> @@
> bool t;
> @@
> - t !=3D true
> + !t
> @@
> bool t;
> @@
> - t =3D=3D false
> + !t
> @@
> bool t;
> @@
> - t !=3D false
> + t
>=20
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    3 +--
>  drivers/net/ethernet/brocade/bna/bfa_cee.c         |    8 ++++----
>  drivers/net/ethernet/brocade/bna/bfa_ioc.c         |    2 +-
>  drivers/net/ethernet/intel/ixgb/ixgb_ee.c          |   12
> +++++-------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |    2 +-
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 +-
>  drivers/net/phy/broadcom.c                         |    6 ++----
>  drivers/net/wireless/ath/ath5k/ani.c               |    8 ++++----
>  drivers/net/wireless/ath/ath9k/ani.c               |    6 +++---
>  drivers/net/wireless/ath/ath9k/hw-ops.h            |    2 +-
>  drivers/net/wireless/ath/ath9k/hw.c                |    5 ++---
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   16
> +++++++---------
>  drivers/net/wireless/brcm80211/brcmsmac/main.c     |    4 ++--
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |    4 ++--
>  drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    2 +-
>  drivers/net/wireless/mwl8k.c                       |    5 ++---
>  drivers/net/wireless/rtlwifi/efuse.c               |    2 +-
>  drivers/net/wireless/rtlwifi/ps.c                  |    3 +--
>  drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    4 ++--
>  drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    8 ++++----
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    9 ++++-----
>  drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    3 +--
>  drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |    3 +--
>  drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    9 ++++-----
>  drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   11 +++++------
>  drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |    6 +++---
>  drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   10 +++++-----
>  drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   13
> ++++++-------
>  drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |    2 +-
>  36 files changed, 85 insertions(+), 101 deletions(-)=20

The ixgbe changes look fine, and I do not see any issues with the
changes.

Reviewed-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

--=-E23QgpvExXo1mIU6Vupx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPNDqXAAoJEOVv75VaS+3OJ7QP+wQ/okr+2VpFzIbrtsH8ObzJ
YRH3E7MQIu0t7E7RVxMADcQyFsP4EALKoGGzZ5tk8VGQU2y3qo7z+Y32kM+K2Gc5
M55GRN25XK8noBJJ1HoN7+jNj6YCp4K578mdkMDweLxq2pAG1KYrvLl3pK1Ch1WP
FVSjuM9yEcvlXDSw6VruD35xsGtLrL7ZysDawyRsojTjSu06w4kQT7TfBlGZBsfV
RJFIg53nem9nIKdjsYjr1B2CE498h/Hek520KloD9ePthL/4ENb6XIGDoLE8HY+/
lAt+GiLiznbMHHfwMG+/ev4+5ytDZ6B7HRfmbmLs6lu+TYhMIEc0M1KehQpAYlL2
q9H7NXVN4qszUrcpeDJlznqqR50xwRvTsKGc8NOtTeLFAaBrR0sJsdHeV7xLsugQ
yFy/gHp9sUsHEeMedly43ySI3cTd+J9VfrRjRKnPEo/gznbAch4zAgx7jrl+kif0
zz/5zqlWDAVWzyO4cYLLhfOXaK3ernol8YwUxh46bg+a4tZJbbH8YaUVIN31Vw0k
9Dx7Qta2DL/ePhVa7AA0zHKreQimlsjy+obHzBlwUttAryGV+A7/0IiwcDA/Da/t
wnzEYj/OsRNlVC/nwLObB9dC0oHJ3TN3I+UShsMUFt9pxrK5ZWZSaKqtjjQRFw/Q
rEeuo1PsgZytmEgwzyS0
=+XsN
-----END PGP SIGNATURE-----

--=-E23QgpvExXo1mIU6Vupx--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
