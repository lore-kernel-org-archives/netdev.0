From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/2] drivers/net: Remove casts of void *
Date: Mon, 13 Jun 2011 21:02:37 -0700
Message-ID: <cover.1308024069.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  wireless: Remove casts of void *
  drivers/net: Remove casts of void *

 drivers/net/a2065.c                            |    2 +-
 drivers/net/appletalk/ltpc.c                   |    8 ++--
 drivers/net/atl1e/atl1e_main.c                 |    5 +--
 drivers/net/atlx/atl2.c                        |    3 +-
 drivers/net/benet/be_cmds.c                    |    3 +-
 drivers/net/benet/be_ethtool.c                 |    4 +-
 drivers/net/bna/bfa_cee.c                      |    2 +-
 drivers/net/bna/cna.h                          |    2 +-
 drivers/net/caif/caif_shmcore.c                |    2 +-
 drivers/net/cnic.c                             |    4 +-
 drivers/net/cxgb3/cxgb3_offload.c              |    2 +-
 drivers/net/davinci_cpdma.c                    |    2 +-
 drivers/net/declance.c                         |   38 ++++++++++++---------
 drivers/net/depca.c                            |    4 +-
 drivers/net/dl2k.c                             |    4 +-
 drivers/net/ehea/ehea_qmr.c                    |    2 +-
 drivers/net/epic100.c                          |    4 +-
 drivers/net/fealnx.c                           |    4 +-
 drivers/net/gianfar.c                          |    4 +-
 drivers/net/hamachi.c                          |    4 +-
 drivers/net/macmace.c                          |    2 +-
 drivers/net/mlx4/en_rx.c                       |    2 +-
 drivers/net/mlx4/en_tx.c                       |    5 +--
 drivers/net/myri_sbus.c                        |    3 +-
 drivers/net/netxen/netxen_nic_ctx.c            |   16 ++++----
 drivers/net/pxa168_eth.c                       |    2 +-
 drivers/net/qla3xxx.c                          |    5 +--
 drivers/net/qlcnic/qlcnic_ctx.c                |   26 +++++++-------
 drivers/net/qlcnic/qlcnic_ethtool.c            |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c                 |    3 +-
 drivers/net/qlcnic/qlcnic_main.c               |    2 +-
 drivers/net/qlge/qlge_main.c                   |    4 +-
 drivers/net/s2io.c                             |   18 ++++------
 drivers/net/sfc/siena.c                        |    2 +-
 drivers/net/sis900.c                           |    4 +-
 drivers/net/tokenring/madgemc.c                |    2 +-
 drivers/net/typhoon.c                          |    2 +-
 drivers/net/vxge/vxge-config.c                 |   44 ++++++++---------------
 drivers/net/vxge/vxge-traffic.c                |    6 ++--
 drivers/net/wan/pc300_tty.c                    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c       |    6 +--
 drivers/net/wireless/ath/ath9k/init.c          |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c           |    2 +-
 drivers/net/wireless/ath/carl9170/usb.c        |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c        |    4 +-
 drivers/net/wireless/hostap/hostap_pci.c       |    4 +-
 drivers/net/wireless/hostap/hostap_plx.c       |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c         |    6 +--
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c    |    2 +-
 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c |    8 ++--
 drivers/net/wireless/iwlegacy/iwl3945-base.c   |    8 ++--
 drivers/net/wireless/iwlegacy/iwl4965-base.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c      |    2 +-
 drivers/net/wireless/mwifiex/11n.c             |    5 +--
 drivers/net/wireless/mwifiex/cmdevt.c          |    3 +-
 drivers/net/wireless/mwifiex/join.c            |    2 +-
 drivers/net/wireless/mwifiex/scan.c            |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c         |    4 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c     |   12 +++---
 drivers/net/wireless/mwifiex/txrx.c            |    2 +-
 drivers/net/wireless/p54/eeprom.c              |    4 +-
 drivers/net/xilinx_emaclite.c                  |    4 +-
 drivers/net/yellowfin.c                        |    6 ++--
 64 files changed, 164 insertions(+), 189 deletions(-)

-- 
1.7.6.rc0
