From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-10-09
Date: Fri, 09 Oct 2015 18:13:22 +0300
Message-ID: <87a8rsqdm5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41015 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbbJIPNa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 11:13:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's first wireless-drivers pull request for 4.4. New features and
bugfixes but not really anything out of ordinary. Please let me know if
there are any problems.

Kalle

The following changes since commit 47bbbb30b4331ec58a74a66a044341f0114b=
02b3:

  sch_dsmark: improve memory locality (2015-09-17 22:37:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-10-09

for you to fetch changes up to 7e64e5e66af8308725bfd03fcdf185c09b3056a7=
:

  Merge tag 'iwlwifi-next-for-kalle-2015-10-05' of git://git.kernel.org=
/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2015-10-07 12:14:23 +03=
00)

----------------------------------------------------------------

Major changes:

iwlwifi

* some debugfs improvements
* fix signedness in beacon statistics
* deinline some functions to reduce size when device tracing is enabled
* filter beacons out in AP mode when no stations are associated
* deprecate firmwares version -12
* fix a runtime PM vs. legacy suspend race
* one-liner fix for a ToF bug
* clean-ups in the rx code
* small debugging improvement
* fix WoWLAN with new firmware versions
* more clean-ups towards multiple RX queues;
* some rate scaling fixes and improvements;
* some time-of-flight fixes;
* other generic improvements and clean-ups;

brcmfmac

* rework code dealing with multiple interfaces
* allow logging firmware console using debug level
* support for BCM4350, BCM4365, and BCM4366 PCIE devices
* fixed for legacy P2P and P2P device handling
* correct set and get tx-power

ath9k

* add support for Outside Context of a BSS (OCB) mode

mwifiex

* add USB multichannel feature

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: avoid memsetting PCIe event buffer
      mwifiex: Suppress -ENOSR error for data traffic on USB

Aniket Nagarnaik (2):
      mwifiex: don't always include ht/vht info in tdls confirm frame
      mwifiex: fix NULL pointer dereference during hidden SSID scan

Arend van Spriel (12):
      brcmfmac: consolidate ifp lookup in driver core
      brcmfmac: make brcmf_proto_hdrpull() return struct brcmf_if insta=
nce
      brcmfmac: change parameters for brcmf_remove_interface()
      brcmfmac: only call brcmf_cfg80211_detach() when attach was succe=
ssful
      brcmfmac: correct detection of p2pdev interface event
      brcmfmac: use brcmf_get_ifp() to map ifidx to struct brcmf_if ins=
tance
      brcmfmac: pass struct brcmf_if instance in brcmf_txfinalize()
      brcmfmac: add mapping for interface index to bsscfg index
      brcmfmac: add dedicated debug level for firmware console logging
      brcmfmac: remove ifidx parameter from brcmf_fws_txstatus_suppress=
ed()
      brcmfmac: change prototype for brcmf_fws_hdrpull()
      brcmfmac: introduce brcmf_net_detach() function

Assaf Krauss (2):
      iwlwifi: mvm: Fix tof debugfs formats (dec vs. hex)
      iwlwifi: mvm: Improve debugfs tof robustness

Aviya Erenfeld (1):
      iwlwifi: mvm: move DTS command and notification to new group

Bartosz Markowski (2):
      ath10k: fix beamformee VHT STS capability
      ath10k: fix beamformer VHT sounding dimensions capability

Bob Copeland (3):
      ath10k: enable monitor when OTHER_BSS requested
      ath10k: check for encryption before adding MIC_LEN
      ath10k: implement mesh support

Dan Carpenter (1):
      mwifiex: fix mwifiex_rdeeprom_read()

Eliad Peller (2):
      iwlwifi: mvm: configure wowlan configuration only if connected
      iwlwifi: mvm: add debug print for d0i3 exit indication

Emmanuel Grumbach (8):
      iwlwifi: mvm: add debugfs hook to send ECHO_CMD to the firmware
      iwlwifi: Deinline iwl_{read,write}(8,32}
      iwlwifi: mvm: don't load -12.ucode anymore
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_HDC_PHASE_0 TLV flag
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_TX_POWER_DEV TLV flag
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_SINGLE_SCAN_EBS TLV flag
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_ASYNC_DTM TLV flag
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_STATS_V10 TLV flag

Eyal Shapira (5):
      iwlwifi: mvm: rs: improve rate debug messages
      iwlwifi: mvm: rs: remove overflowing debug message
      iwlwifi: mvm: rs: minor indentation fix
      iwlwifi: mvm: rs: fix success ratio comparison in rs_get_best_rat=
e
      iwlwifi: mvm: rs: dynamically switch between 80MHz and 20MHz in s=
ome scenarios

Geoff Levand (1):
      net/wireless/wl18xx: Add missing MODULE_FIRMWARE

Gregory Greenman (2):
      iwlwifi: mvm: don't ask for beacons when AP vif and no assoc sta
      iwlwifi: mvm: ToF - fill bssid of responder configuration

Guodong Xu (1):
      wlcore: align reg_ch_conf_last[] to 64bit

Hante Meuleman (17):
      brcmfmac: Reset PCIE devices after recognition.
      brcmfmac: Fix exception handling.
      brcmfmac: Add support for the BCM4350 PCIE device.
      brcmfmac: Fix set and get tx-power functions.
      brcmfmac: Only assign primary netdev to if2bss array.
      brcmfmac: Inform p2p module about p2pon through API
      brcmfmac: Fix bug in flowring management.
      brcmfmac: Make p2pon module param always available.
      brcmfmac: Workaround in change vif for wpa_supplicant support.
      brcmfmac: Deleting of p2p device is leaking memory.
      brcmfmac: Only handle p2p_stop_device if vif is valid
      brcmfmac: Fix p2p bug for older firmwares.
      brcmfmac: Add module parameter to disable features.
      brcmfmac: Fix race condition bug when deleting p2p interface.
      brcmfmac: Add support for the BCM4365 and BCM4366 PCIE devices.
      brcmfmac: Fix TDLS setup by properly handling p2p noif.
      brcmfmac: Accept events when TDLS is used in combination with p2p=
=2E

Hauke Mehrtens (2):
      brcmfmac: include linux/atomic.h
      bcma: add support for population subnodes also when build as modu=
le

Hiroaki KAWAI (1):
      carl9170: fix bad rssi reading

Ilan Peer (1):
      iwlwifi: mvm: Correctly update MAC context on add/del station

Jan Kaisrlik (1):
      ath9k: Add support for OCB mode

Janusz Dziedzic (1):
      ath10k: fix MSI-X registering for qca99x0

Joe Perches (1):
      mwifiex: Make mwifiex_dbg a function, reduce object size

Johannes Berg (19):
      iwlwifi: mvm: don't NUL-terminate low-latency debugfs file
      iwlwifi: mvm: make sure AP is operating for ToF
      iwlwifi: mvm: remove useless debug message from RX
      iwlwifi: mvm: remove pointless cfg_phy_cnt length check
      iwlwifi: mvm: remove some unused defines from RX API
      iwlwifi: mvm: move RX API into its own file
      iwlwifi: mvm: correct skip-over-DTIM implementation
      MAINTAINERS: iwlwifi: update contact email
      iwlwifi: enable tracing by default
      iwlwifi: mvm: remove PHY RX from handlers
      iwlwifi: op-mode API: add rx_rss method
      iwlwifi: transport: track number of allocated queues
      iwlwifi: mvm: stop using DEVICE_POWER_FLAGS_CAM_MSK
      iwlwifi: remove IWL3165_UCODE_API_OK and _MIN
      iwlwifi: mvm: minor rx code cleanup
      iwlwifi: mvm: fix signedness warnings in ToF debugfs
      iwlwifi: mvm: make threshold temperatures unsigned
      iwlwifi: size firmware flags memory correctly
      iwlwifi: mvm: add minimal multi-RXQ infrastructure

Kalle Valo (4):
      ath10k: add ATH10K_FW_FEATURE_RAW_MODE_SUPPORT to ath10k_core_fw_=
feature_str[]
      Merge tag 'iwlwifi-next-for-kalle-2015-09-21' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2015-10-05' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next

Liad Kaufman (4):
      iwlwifi: mvm: remove SCD_QUEUE_CONFIG TLV flag
      iwlwifi: mvm: fix default disabled aggs in sta
      iwlwifi: mvm: support using multiple ACs on single HW queue
      iwlwifi: mvm: support enabling a queue with a given ssn

Luciano Coelho (2):
      iwlwifi: mvm: remove netdetect debugfs entry
      iwlwifi: mvm: make sure d0i3 exit work runs before suspending

Manikanta Pubbisetty (1):
      ath10k: print invalid mcs reported in rx descriptor

Miaoqing Pan (1):
      ath9k: enable hw manual peak calibration for QCA9561

Michal Kazior (4):
      ath10k: fix mu-mimo rx status reporting
      ath10k: move hw_scan worker queuing
      ath10k: split switch_vif_chanctx guts
      ath10k: handle IEEE80211_CHANCTX_CHANGE_WIDTH properly

Moshe Harel (2):
      iwlwifi: nvm: force 1x1 antenna in Series 8000
      iwlwifi: nvm: add nvm phy_sku section to debugfs

Nicolas Iooss (1):
      iwlwifi: mvm: fix tof.h header guard

Oleksij Rempel (1):
      ath9k_htc: introduce support for different fw versions

Ondrej Zary (2):
      airo: fix IW_AUTH_ALG_OPEN_SYSTEM
      airo: Implement netif_carrier_on/off

Peter Oh (2):
      ath: fix incorrect PPB on JAPAN chirp radar
      ath: use PRI value given by spec for fixed PRI

Rafa=C5=82 Mi=C5=82ecki (4):
      ssb: unexport ssb_bus_pcibus_register
      ssb: make ssb_sdio_switch_core static
      ssb: drop declaration of non existing ssb_sdio_hardware_setup
      ssb: make ssb_pcmcia_switch_core static

Rajkumar Manoharan (1):
      ath10k: fix ldpc param for fixed rate

Sara Sharon (1):
      iwlwifi: mvm: fix statistics variables type

Vasanthakumar Thiagarajan (1):
      ath10k: fix DMA alloc failure for target requested memory chunks

Vivek Natarajan (1):
      ath10k: drop probe responses when too many are queued

Xinming Hu (4):
      mwifiex: fix typo in del_virtual_intf() function
      mwifiex: minor corrections in multiport aggregation code
      mwifiex: fix driver init failure under memory pressure
      mwifiex: NULL check for cfg80211_inform_bss()

Zhaoyang Liu (8):
      mwifiex: update amsdu tx packet time stamp
      mwifiex: correct paused tx data packet counter
      mwifiex: fix tx data_sent issue for usb interface
      mwifiex: move usb specific data_sent update to usb.c
      mwifiex: add usb multi channel event process support
      mwifiex: add usb tx data multi endpoints support
      mwifiex: add usb multi endpoints resync support
      mwifiex: complete usb tx data with multi endpoints

 MAINTAINERS                                        |    2 +-
 drivers/bcma/main.c                                |    9 +-
 drivers/net/wireless/airo.c                        |   64 ++--
 drivers/net/wireless/ath/ath10k/core.c             |   23 ++
 drivers/net/wireless/ath/ath10k/core.h             |    5 +
 drivers/net/wireless/ath/ath10k/htt.h              |    3 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   47 ++-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   55 +++-
 drivers/net/wireless/ath/ath10k/hw.h               |   10 -
 drivers/net/wireless/ath/ath10k/mac.c              |  333 ++++++++++++=
++------
 drivers/net/wireless/ath/ath10k/pci.c              |   18 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |   14 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   76 ++++-
 drivers/net/wireless/ath/ath10k/wmi.h              |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |    4 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |  106 +++++--
 drivers/net/wireless/ath/ath9k/hif_usb.h           |   21 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    1 +
 drivers/net/wireless/ath/ath9k/init.c              |    3 +-
 drivers/net/wireless/ath/ath9k/main.c              |    8 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/carl9170/rx.c             |    2 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c    |    8 +-
 drivers/net/wireless/ath/dfs_pattern_detector.h    |    5 +
 drivers/net/wireless/ath/dfs_pri_detector.c        |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |   28 +-
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c   |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  193 ++++--------
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.h |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |  129 +++++++-
 drivers/net/wireless/brcm80211/brcmfmac/chip.h     |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |  116 ++++---
 drivers/net/wireless/brcm80211/brcmfmac/core.h     |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/debug.h    |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |   15 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.h |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   39 ++-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |   57 ++--
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   18 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |   92 ++++--
 drivers/net/wireless/brcm80211/brcmfmac/p2p.h      |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |  104 ++++--
 drivers/net/wireless/brcm80211/brcmfmac/proto.h    |   18 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |    6 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   11 +
 drivers/net/wireless/iwlwifi/Kconfig               |    1 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   12 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   32 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   23 ++
 drivers/net/wireless/iwlwifi/iwl-io.h              |   21 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   15 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   19 +-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    5 +
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    1 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    3 +
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |   75 +++--
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  132 ++------
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    8 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rx.h       |  238 ++++++++++++=
++
 drivers/net/wireless/iwlwifi/mvm/fw-api-stats.h    |   41 +--
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  196 +-----------
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   24 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   36 ++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   26 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   68 ++--
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |    7 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  178 ++++++++---
 drivers/net/wireless/iwlwifi/mvm/power.c           |   80 +++--
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  116 ++++++-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   67 ++--
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    2 -
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   83 +++--
 drivers/net/wireless/iwlwifi/mvm/tof.c             |    4 +-
 drivers/net/wireless/iwlwifi/mvm/tof.h             |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   11 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |  141 +++++++--
 drivers/net/wireless/mwifiex/11n_aggr.c            |    8 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   12 +-
 drivers/net/wireless/mwifiex/debugfs.c             |   14 +-
 drivers/net/wireless/mwifiex/fw.h                  |   18 ++
 drivers/net/wireless/mwifiex/init.c                |    1 +
 drivers/net/wireless/mwifiex/main.c                |   80 ++++-
 drivers/net/wireless/mwifiex/main.h                |   25 +-
 drivers/net/wireless/mwifiex/pcie.c                |    1 -
 drivers/net/wireless/mwifiex/scan.c                |   22 +-
 drivers/net/wireless/mwifiex/sdio.c                |   29 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    3 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   11 +
 drivers/net/wireless/mwifiex/sta_event.c           |   78 ++++-
 drivers/net/wireless/mwifiex/sta_tx.c              |    7 +-
 drivers/net/wireless/mwifiex/tdls.c                |   12 +
 drivers/net/wireless/mwifiex/txrx.c                |   19 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    4 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   10 +-
 drivers/net/wireless/mwifiex/usb.c                 |  224 ++++++++++--=
-
 drivers/net/wireless/mwifiex/usb.h                 |   15 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   52 ++-
 drivers/net/wireless/ti/wl18xx/main.c              |    1 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |    2 +-
 drivers/ssb/main.c                                 |    1 -
 drivers/ssb/pcmcia.c                               |    3 +-
 drivers/ssb/sdio.c                                 |    2 +-
 drivers/ssb/ssb_private.h                          |   18 --
 include/linux/bcma/bcma.h                          |    2 +
 117 files changed, 2677 insertions(+), 1410 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-rx.h

--=20
Kalle Valo
