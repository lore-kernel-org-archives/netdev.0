From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 00/14] Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:45 -0800
Message-ID: <cover.1425354527.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-bluetooth@vger.kernel.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath10k@lists.infradead.org, ath9k-devel@lists.ath9k.org,
	b43-dev@lists.infradead.org, libertas-dev@lists.infradead.org,
	xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (14):
  etherdevice: Add eth_<foo>_addr CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
  ethernet: Use eth_<foo>_addr instead of memset
  net: usb: Use eth_<foo>_addr instead of memset
  wireless: Use eth_<foo>_addr instead of memset
  netconsole: Use eth_<foo>_addr instead of memset
  xen: Use eth_<foo>_addr instead of memset
  8021q: Use eth_<foo>_addr instead of memset
  appletalk: Use eth_<foo>_addr instead of memset
  atm: Use eth_<foo>_addr instead of memset
  bluetooth: Use eth_<foo>_addr instead of memset
  ethernet: Use eth_<foo>_addr instead of memset
  mac80211: Use eth_<foo>_addr instead of memset
  wireless: Use eth_<foo>_addr instead of memset
  l2tp: Use eth_<foo>_addr instead of memset

 drivers/net/ethernet/amd/pcnet32.c                 |  2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  6 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |  8 +++---
 drivers/net/ethernet/emulex/benet/be_cmds.c        |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c              |  2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |  2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |  2 +-
 drivers/net/ethernet/ti/netcp_core.c               |  2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |  4 +--
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |  2 +-
 drivers/net/netconsole.c                           |  5 ++--
 drivers/net/usb/catc.c                             |  4 +--
 drivers/net/usb/cdc_mbim.c                         |  2 +-
 drivers/net/usb/lg-vl600.c                         |  2 +-
 drivers/net/usb/qmi_wwan.c                         |  2 +-
 drivers/net/wireless/airo.c                        |  4 +--
 drivers/net/wireless/at76c50x-usb.c                |  6 ++--
 drivers/net/wireless/ath/ath10k/mac.c              |  2 +-
 drivers/net/wireless/ath/ath5k/base.c              |  2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  2 +-
 drivers/net/wireless/ath/ath6kl/main.c             |  2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  2 +-
 drivers/net/wireless/ath/ath9k/main.c              |  4 +--
 drivers/net/wireless/atmel.c                       | 16 +++++------
 drivers/net/wireless/b43/main.c                    |  8 +++---
 drivers/net/wireless/b43legacy/main.c              |  8 +++---
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c | 12 ++++----
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  2 +-
 drivers/net/wireless/cw1200/sta.c                  |  2 +-
 drivers/net/wireless/cw1200/txrx.c                 |  2 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |  4 +--
 drivers/net/wireless/hostap/hostap_ap.c            |  8 +++---
 drivers/net/wireless/hostap/hostap_info.c          |  2 +-
 drivers/net/wireless/hostap/hostap_main.c          |  4 +--
 drivers/net/wireless/hostap/hostap_wlan.h          | 33 +++++++++++-----------
 drivers/net/wireless/ipw2x00/ipw2100.c             |  8 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c             |  6 ++--
 drivers/net/wireless/iwlegacy/common.c             |  2 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |  3 +-
 drivers/net/wireless/libertas/main.c               |  4 +--
 drivers/net/wireless/libertas_tf/main.c            |  4 +--
 drivers/net/wireless/mac80211_hwsim.c              |  6 ++--
 drivers/net/wireless/mwifiex/cfg80211.c            |  8 +++---
 drivers/net/wireless/mwifiex/init.c                |  4 +--
 drivers/net/wireless/mwifiex/sta_event.c           |  2 +-
 drivers/net/wireless/mwifiex/wmm.c                 |  2 +-
 drivers/net/wireless/mwl8k.c                       |  2 +-
 drivers/net/wireless/orinoco/wext.c                |  2 +-
 drivers/net/wireless/p54/fwio.c                    |  2 +-
 drivers/net/wireless/p54/main.c                    |  8 +++---
 drivers/net/wireless/ray_cs.c                      |  2 +-
 drivers/net/wireless/rndis_wlan.c                  | 28 +++++++++---------
 drivers/net/wireless/rtlwifi/core.c                |  6 ++--
 drivers/net/wireless/ti/wl1251/main.c              |  4 +--
 drivers/net/wireless/ti/wlcore/cmd.c               |  4 +--
 drivers/net/xen-netback/interface.c                |  2 +-
 include/linux/etherdevice.h                        | 12 +++++++-
 net/8021q/vlan_dev.c                               |  2 +-
 net/appletalk/aarp.c                               |  6 ++--
 net/atm/lec.c                                      |  4 +--
 net/bluetooth/bnep/netdev.c                        |  2 +-
 net/ethernet/eth.c                                 |  4 +--
 net/l2tp/l2tp_eth.c                                |  2 +-
 net/mac80211/cfg.c                                 |  2 +-
 net/mac80211/ibss.c                                |  2 +-
 net/mac80211/mesh.c                                |  2 +-
 net/mac80211/mlme.c                                | 10 +++----
 net/wireless/ibss.c                                |  2 +-
 net/wireless/nl80211.c                             |  4 +--
 net/wireless/trace.h                               |  9 +++---
 net/wireless/wext-sme.c                            |  2 +-
 79 files changed, 190 insertions(+), 176 deletions(-)

-- 
2.1.2
