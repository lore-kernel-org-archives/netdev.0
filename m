From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] net,drivers/net: Use ether_addr_equal and ether_addr_equal_64bits
Date: Wed,  9 May 2012 20:04:01 -0700
Message-ID: <cover.1336618707.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	ath9k-devel@lists.ath9k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43374 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754719Ab2EJDEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 23:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches (3):
  drivers/net: Convert compare_ether_addr to ether_addr_equal
  etherdevice.h: Add ether_addr_equal_64bits
  net,drivers/net: Convert compare_ether_addr_64bits to ether_addr_equal_64bits

 drivers/net/bonding/bond_alb.c                    |   58 ++++++++++----------
 drivers/net/bonding/bond_main.c                   |    2 +-
 drivers/net/ethernet/amd/depca.c                  |    3 +-
 drivers/net/ethernet/cisco/enic/enic_main.c       |   12 ++---
 drivers/net/ethernet/dec/ewrk3.c                  |    3 +-
 drivers/net/ethernet/dec/tulip/de4x5.c            |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c  |    5 +-
 drivers/net/ethernet/sfc/ethtool.c                |    2 +-
 drivers/net/ethernet/sun/sunvnet.c                |    2 +-
 drivers/net/ethernet/tile/tilepro.c               |    2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c |    8 ++--
 drivers/net/macvlan.c                             |    7 +--
 drivers/net/tun.c                                 |    2 +-
 drivers/net/wireless/at76c50x-usb.c               |    2 +-
 drivers/net/wireless/ath/ath5k/base.c             |    6 +-
 drivers/net/wireless/ath/ath9k/recv.c             |    2 +-
 drivers/net/wireless/ath/carl9170/rx.c            |    2 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c          |   16 +++---
 drivers/net/wireless/iwlegacy/3945.c              |    4 +-
 drivers/net/wireless/iwlegacy/4965-mac.c          |    2 +-
 drivers/net/wireless/iwlegacy/common.c            |   14 +++---
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c       |    8 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c        |    6 +-
 drivers/net/wireless/mwl8k.c                      |    2 +-
 drivers/net/wireless/p54/txrx.c                   |    2 +-
 drivers/net/wireless/rndis_wlan.c                 |   12 ++--
 drivers/net/wireless/rtlwifi/base.c               |    2 +-
 drivers/net/wireless/rtlwifi/ps.c                 |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      |   10 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |   10 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      |   11 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c      |   11 ++--
 include/linux/etherdevice.h                       |   20 +++++++
 net/ethernet/eth.c                                |    5 +-
 35 files changed, 140 insertions(+), 121 deletions(-)

-- 
1.7.8.111.gad25c.dirty
