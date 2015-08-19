From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-08-19
Date: Wed, 19 Aug 2015 14:03:56 +0300
Message-ID: <87pp2ja6ar.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57306 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbbHSLEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 07:04:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's one more pull request for 4.3. More info in the signed tag below.

This time I had to merge mac80211-next.git due to some iwlwifi
dependencies and apparently that broke git-request-pull's diffstat
again, it was showing changes which were not really coming from my tree.
I think that's just a bug in my old git and really should update the
tool. This time I just fixed the diffstat manually.

But please be extra careful with this pull request and please let me
know if you have any problems.

The following changes since commit 8f9c98df949333f08b74e5df1caacf7e2c5e8552:

  mac80211: fix BIT position for TDLS WIDE extended cap (2015-08-14 17:49:53 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-08-19

for you to fetch changes up to a6bf49db8c94d194d1c197deba2935468026ec89:

  Merge tag 'iwlwifi-next-for-kalle-2015-08-18' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2015-08-18 17:20:11 +0300)

----------------------------------------------------------------

Major changes:

ath10k:

* add support for qca99x0 family of devices
* improve performance of tx_lock
* add support for raw mode (802.11 frame format) and software crypto
  engine enabled via a module parameter

ath9k:

* add fast-xmit support

wil6210:

* implement TSO support
* support bootloader v1 and onwards

iwlwifi:

* Deprecate -10.ucode
* Clean ups towards multiple Rx queues
* Add support for longer CMD IDs. This will be required by new
  firmwares since we are getting close to the u8 limit.
* bugfixes for the D0i3 power state
* Add basic support for FTM
* polish the Miracast operation
* fix a few power consumption issues
* scan cleanup
* fixes for D0i3 system state
* add paging for devices that support it
* add again the new RBD allocation model
* add more options to the firmware debug system
* add support for frag SKBs in Tx

----------------------------------------------------------------
Adrien Schildknecht (2):
      rt2x00: adjust EEPROM_SIZE for rt2500usb
      iwlwifi: out-of-bounds access in iwl_init_sband_channels

Alexander Bondar (2):
      iwlwifi: Add max TX aggregation size for 8260 SDIO devices series
      iwlwifi: rs: disable MIMO only if allowed in configuration

Amitkumar Karwar (3):
      mwifiex: corrections in PCIe event skb handling
      mwifiex: add missing skb_push() in mwifiex_check_uap_capabilties
      mwifiex: correct TDLS link delete failure message priority

Andreas Fenkart (5):
      mwifiex: sdio: reset adapter using mmc_hw_reset
      mwifiex: remove explicit mwifiex_complete_cmd calls
      mwifiex: remove redundant reset of cmd_wait_q status
      mwifiex: remove CMD_F_CANCELED flag
      mwifiex: simplify mwifiex_complete_cmd

Andy Shevchenko (1):
      iwlwifi: convert hex_dump_to_buffer() to %*ph

Aniket Nagarnaik (1):
      mwifiex: claim sdio bus while downloading the firmware

Arik Nemtsov (1):
      iwlwifi: mvm: support TDLS wider-bandwidth

Assaf Krauss (1):
      iwlwifi: mvm: ToF - Set correct range request cmd id

Aviya Erenfeld (1):
      iwlwifi: add wide firmware command infrastructure for TX

Avraham Stern (2):
      iwlwifi: mvm: add wide firmware command infrastructure for RX
      iwlwifi: add new TLV capability flag for gscan support

Avri Altman (5):
      iwlwifi: mvm: update comment of power_scheme module parameter
      iwlwifi: mvm: Enable Rx Checksum hw
      iwlwifi: mvm: revert to our old skip over dtim policy
      iwlwifi: mvm: set different pm_timeout for action frames
      iwlwifi: mvm: Enable power management on low-latency bss

Ayala Beker (1):
      iwlwifi: mvm: add debug info to schedule scan complete message.

Bertold Van den Bergh (1):
      ath: Make ath_opmode_to_string understand OCB mode

Cheolhyun Park (1):
      rtlwifi: misspelled code and comments corrected.

Dan Carpenter (2):
      mwifiex: usb: return an error if kmalloc fails
      iwlwifi: mvm: fix a range check in debugfs code

David Liu (1):
      ath10k: enable raw encap mode and software crypto engine

David Spinadel (4):
      iwlwifi: mvm: clean up fw-api-scan.h
      iwlwifi: mvm: simplify calculating scan dwells and other timing values
      iwlwifi: mvm: remove partial and full scan lists from lmac sched scan
      iwlwifi: mvm: don't disconnect on beacon loss in D0I3

Dedy Lansky (1):
      wil6210: treat "unhandled event" as warning instead of error

Dor Shaish (1):
      iwlwifi: mvm: print secboot status registers on alive timeout

Eliad Peller (9):
      Revert "iwlwifi: mvm: move deferred d0i3 exit to resume_complete op"
      iwlwifi: return error if d0i3 was aborted
      iwlwifi: call d3_suspend/resume in d0i3 case as well
      iwlwifi: pcie: reset write pointer on ict reset
      wl18xx: use long intervals in sched scan
      wlcore: add generic_cfg_feature command definitions
      wlcore: add p2p device support
      iwlwifi: make sure d3_suspend/resume ops exist
      wl18xx: update statistics acx and debugfs files

Emmanuel Grumbach (10):
      iwlwifi: dvm: start HW before running FW
      iwlwifi: pcie: lock start_hw / start_fw / stop_device
      iwlwifi: pcie: cancel Tx timer upon firmware crash
      iwlwifi: pcie: add missing calls to synchronize_irq()
      iwlwifi: pcie: don't warn on long MPDUs when supported
      iwlwifi: pcie: dump RBs when FW error occurs
      Merge remote-tracking branch 'iwlwifi-fixes/master' into next
      Merge tag 'mac80211-next-for-davem-2015-08-14' into next
      iwlwifi: bump mvm firmware API to 16
      iwlwifi: mvm: fix a race in D0i3 vs. Tx path

Eyal Shapira (1):
      iwlwifi: mvm: rs: report last tx rate based on RSSI and caps

Felix Fietkau (4):
      ath9k: add fast-xmit support
      ath9k: remove struct ath_atx_ac
      ath9k: remove the sched field in struct ath_atx_tid
      ath9k: fix build with CONFIG_ATH9K_STATION_STATISTICS=y

Gregory Greenman (3):
      iwlwifi: mvm: add basic Time of Flight (802.11mc FTM) support
      iwlwifi: mvm: fix beacon filtering temperature thresholds for D0i3
      iwlwifi: mvm: ignore CQM when setting beacon filtering in D0i3 enter flow

Guy Mishol (3):
      wl18xx: add dynamic fw traces
      wlcore: add antenna diversity reading comments
      wl18xx: add diversity statistics

Haim Dreyfuss (2):
      iwlwifi: pcie: Set scheduler to work on auto mode
      iwlwifi: pcie: provide a way to stop configuration if it is forbidden

Hauke Mehrtens (1):
      bcma: fix access to host_pdev for PCIe devices

Ilan Peer (2):
      iwlwifi: mvm: Do not sample the device time for session protection
      iwlwifi: mvm: Use the AP station for non_sta transmit

Jakub Kicinski (4):
      mt7601u: fix dma from stack address
      mt7601u: use correct ieee80211_rx variant
      mt7601u: fix tx status reporting contexts
      mt7601u: lock out rx path and tx status reporting

Janusz.Dziedzic@tieto.com (4):
      ath9k: advertise p2p dev support when chanctx
      ath9k: handle RoC cancel correctly
      ath9k: setup rxfilter for all chanctx
      ath9k: setup rxfilter when offchannel

Jes Sorensen (1):
      orinoco: Do not call wiphy_unregister() from free_orinocodev()

Johannes Berg (12):
      iwlwifi: mvm: handle RX MPDUs separately
      iwlwifi: mvm: LRU-assign key offsets
      iwlwifi: dvm: move ADD_STA response handling to sync command
      iwlwifi: dvm: remove ADD_STA prints relying on station ID
      iwlwifi: dvm: remove command/return value from RX handlers
      iwlwifi: mvm: remove command/return value from RX handlers
      iwlwifi: remove command and return value from opmode RX
      iwlwifi: remove command header flags field
      iwlwifi: mvm: move existing UMAC commands to group 1
      iwlwifi: mvm: move TX PN assignment for CCMP to the driver
      iwlwifi: pcie: support frag SKBs
      iwlwifi: pass NAPI struct from transport layer

John Linville (1):
      mwl8k: refactor some conditionals for clarity

Kalle Valo (4):
      Merge tag 'iwlwifi-next-for-kalle-2015-08-04' of https://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git. Major changes in ath10k:
      Merge tag 'mac80211-next-for-davem-2015-08-14' mac80211-next.git
      Merge tag 'iwlwifi-next-for-kalle-2015-08-18' of https://git.kernel.org/.../iwlwifi/iwlwifi-next

Kevin Darbyshire-Bryant (1):
      ath10k: suppress 'failed to process fft' warning messages

Larry Finger (7):
      rtlwifi: rtl8192ce: rtl8192cu: Fix endian issue
      rtlwifi: rtl8723ae: rtl8723be: rtl8723com: Fix firmware header endian issues
      rtlwifi: rtl8821ae: Fix firmware endian issues
      rtlwifi: rtl8192de: Fix firmware header endian issues
      rtlwifi: rtl888ee: Fix firmware header endian issues
      rtlwifi: rtl8192ee: Fix firmware header endian issues
      rtlwifi: rtl8192c-common: Fix two typos

Linus Walleij (1):
      bcma: switch GPIO portions to use GPIOLIB_IRQCHIP

Machani, Yaniv (1):
      wlcore/wl18xx : add time sync event handling

Manikanta Pubbisetty (1):
      ath10k: add TCP/UDP Checksum offload support for QCA99x0

Maninder Singh (1):
      ath10k: fix wrong initialization of struct channel

Matti Gottlieb (2):
      iwlwifi: mvm: Add FW paging mechanism for the UMAC on PCI
      iwlwifi: mvm: Add FW paging mechanism for the UMAC on SDIO

Miaoqing Pan (1):
      ath9k: add correct MAC/BB name for ar9561

Michal Kazior (6):
      ath10k: remove futile fragmentation threshold config
      ath10k: reject 11b tx fragmentation configuration
      ath10k: initialize fw_features var
      ath10k: fix hw reconfig on wow failure
      ath10k: don't remove peer that doesn't exist
      ath10k: fix peer limit enforcement

Nicholas Krause (1):
      iwlwifi: make various functions void in the file rs.c

Nicholas Mc Guire (4):
      ath9k_htc: match wait_for_completion_timeout return type
      ath9k_htc: drv_init: match wait_for_completion_timeout return type
      ath9k_htc: wmi: match wait_for_completion_timeout return type
      ath9k: match wait_for_completion_timeout return type

Nik Nyby (1):
      ath6kl: spell "distribution" correctly in a comment.

Oren Givon (1):
      iwlwifi: mvm: add the ability to trigger only monitor dumps

Peter Oh (4):
      ath10k: update tx path to support QCA99X0
      ath10k: redefine rx_ppdu_end_common structure to cover qca99x0
      ath10k: add support for qca99x0 Rx descriptors
      ath10k: initialize msdu ext. descriptor before use

Qi Zhou (1):
      ath10k: Improve performance by reducing tx_lock contention

Raja Mani (3):
      ath10k: extend struct htt_mgmt_tx_dec for qca99x0
      ath10k: fix memory alloc failure in qca99x0 during wmi svc rdy event
      ath10k: increase max client to 512 in qca99x0

Sara Sharon (5):
      iwlwifi: deprecate -10.ucode for 3160 / 7260 / 7265
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_BASIC_DWELL
      iwlwifi: add wide firmware command support for notifications
      iwlwifi: mvm: add wide firmware command support for debug triggers
      iwlwifi: pcie: New RBD allocation model

Taehee Yoo (2):
      rtlwifi: rtl8192cu: remove duplicated routine in hw.c and mac.c
      rtlwifi: rtl8192cu: Remove and replace routine in hw.c and mac.c

Vasanthakumar Thiagarajan (2):
      ath10k: delay device access after cold reset
      ath10k: add QCA99X0 to supported device list

Vineet Gupta (1):
      brcmfmac: dhd_sdio.c: use existing atomic_or primitive

Vivek Natarajan (2):
      ath10k: Support different txbf configuration schemes
      ath10k: Enable MU MIMO txbf support for QCA99X0

Vladimir Kondratiev (17):
      wil6210: support boot loader struct v0 & v1
      wil6210: count drops in Rx block ack reorder
      wil6210: print "ulong" fields in hex format in the debugfs
      wil6210: use <> vs. "" for global include
      wil6210: wait for del_station to complete
      wil6210: use wil_fw_error_recovery()
      wil6210: skip HW version check for chip debugging
      wil6210: TSO implementation
      wil6210: improve mgmt frame handling
      wil6210: sort IEs handling
      wil6210: unify wmi_set_ie() error handling
      wil6210: detailed statistics for Rx reorder drop
      wil6210: remove 3-MSI support
      wil6210: use inline functions for register access
      wil6210: system power management
      wil6210: report boot loader error
      wil6210: support future boot loaders

Vladimir Shulman (1):
      wil6210: allow to handle Rx on 2 cores

Xinming Hu (1):
      mwifiex: using right aid value for tdls action frame

Zhaoyang Liu (4):
      mwifiex: fix command timeout for PCIe chipsets
      mwifiex: fix system crash observed during initialisation
      mwifiex: add support for 8997 chipset
      mwifiex: add firmware dump support for SD8997

chunfan chen (1):
      mwifiex: fix unable to connect hidden SSID AP on DFS channel

 drivers/bcma/Kconfig                               |    2 +-
 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/driver_gpio.c                         |   92 +--
 drivers/bcma/main.c                                |   30 +-
 drivers/net/wireless/ath/ath10k/core.c             |   54 +-
 drivers/net/wireless/ath/ath10k/core.h             |   36 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   21 +-
 drivers/net/wireless/ath/ath10k/htt.c              |   23 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   44 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   43 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   61 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   16 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  169 ++++-
 drivers/net/wireless/ath/ath10k/pci.c              |   22 +-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |  173 ++++-
 drivers/net/wireless/ath/ath10k/txrx.c             |   17 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   10 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   10 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   50 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   11 +
 drivers/net/wireless/ath/ath10k/wow.c              |   20 +-
 drivers/net/wireless/ath/ath6kl/htc.h              |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   22 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   23 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c         |   20 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    9 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    1 +
 drivers/net/wireless/ath/ath9k/init.c              |    8 +-
 drivers/net/wireless/ath/ath9k/link.c              |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   11 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    3 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  145 ++--
 drivers/net/wireless/ath/debug.c                   |    2 +
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/boot_loader.h     |   61 ++
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   95 +--
 drivers/net/wireless/ath/wil6210/debugfs.c         |   16 +-
 drivers/net/wireless/ath/wil6210/ethtool.c         |   14 +-
 drivers/net/wireless/ath/wil6210/fw.c              |   10 -
 drivers/net/wireless/ath/wil6210/fw_inc.c          |   16 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |  165 ++---
 drivers/net/wireless/ath/wil6210/ioctl.c           |    4 +-
 drivers/net/wireless/ath/wil6210/main.c            |  198 ++++--
 drivers/net/wireless/ath/wil6210/netdev.c          |    5 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |  127 ++--
 drivers/net/wireless/ath/wil6210/pm.c              |   98 +++
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |    6 +
 drivers/net/wireless/ath/wil6210/txrx.c            |  383 +++++++++-
 drivers/net/wireless/ath/wil6210/txrx.h            |    8 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |   62 +-
 drivers/net/wireless/ath/wil6210/wil_platform.c    |    2 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  130 +++-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |   13 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   19 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |    8 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    5 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    8 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   14 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   13 -
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   51 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |  105 +--
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |    3 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |   25 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |  111 +--
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   18 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    5 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    3 +
 drivers/net/wireless/iwlwifi/iwl-devtrace-data.h   |    7 +-
 .../net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h    |   14 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   72 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    6 -
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |   17 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   50 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   68 ++
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.h      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   32 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   12 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  125 +++-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    1 +
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   44 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   31 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    1 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   74 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |  751 ++++++++++++++++++++
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |    9 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  147 ----
 drivers/net/wireless/iwlwifi/mvm/fw-api-tof.h      |  386 ++++++++++
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |   12 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   86 ++-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  389 +++++++++-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   13 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   63 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  155 ++--
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   23 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  113 +--
 drivers/net/wireless/iwlwifi/mvm/power.c           |   46 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  160 ++++-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   10 +
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   43 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  325 ++++-----
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   41 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    5 +-
 drivers/net/wireless/iwlwifi/mvm/tdls.c            |   33 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   14 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    5 +-
 drivers/net/wireless/iwlwifi/mvm/tof.c             |  304 ++++++++
 drivers/net/wireless/iwlwifi/mvm/tof.h             |   94 +++
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   13 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   94 ++-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   13 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   17 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   64 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  496 ++++++++++---
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  414 ++++++++---
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  135 +++-
 drivers/net/wireless/mediatek/mt7601u/dma.c        |   34 +-
 drivers/net/wireless/mediatek/mt7601u/init.c       |    2 +
 drivers/net/wireless/mediatek/mt7601u/mac.c        |    4 +
 drivers/net/wireless/mediatek/mt7601u/mt7601u.h    |   10 +-
 drivers/net/wireless/mediatek/mt7601u/tx.c         |    3 +
 drivers/net/wireless/mediatek/mt7601u/usb.c        |   63 +-
 drivers/net/wireless/mediatek/mt7601u/usb.h        |    2 +
 drivers/net/wireless/mwifiex/Kconfig               |   12 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   39 +-
 drivers/net/wireless/mwifiex/fw.h                  |    2 +-
 drivers/net/wireless/mwifiex/init.c                |    7 +-
 drivers/net/wireless/mwifiex/main.h                |    2 +
 drivers/net/wireless/mwifiex/pcie.c                |   14 +-
 drivers/net/wireless/mwifiex/pcie.h                |   45 +-
 drivers/net/wireless/mwifiex/scan.c                |  143 +++-
 drivers/net/wireless/mwifiex/sdio.c                |  207 +++++-
 drivers/net/wireless/mwifiex/sdio.h                |   77 ++
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/mwifiex/tdls.c                |    2 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    2 +
 drivers/net/wireless/mwifiex/usb.c                 |   18 +-
 drivers/net/wireless/mwifiex/usb.h                 |    3 +
 drivers/net/wireless/mwifiex/util.c                |   16 +-
 drivers/net/wireless/mwl8k.c                       |   49 +-
 drivers/net/wireless/orinoco/main.c                |    2 -
 drivers/net/wireless/orinoco/orinoco_cs.c          |    1 +
 drivers/net/wireless/orinoco/orinoco_nortel.c      |    5 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |    5 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |    5 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    2 +
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |   21 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   19 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   94 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   93 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |   10 -
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h        |   22 -
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.h        |   21 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |    4 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |   10 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   19 -
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c        |   14 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h        |   23 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   25 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |    6 +-
 drivers/net/wireless/ti/wl18xx/acx.c               |   27 +
 drivers/net/wireless/ti/wl18xx/acx.h               |  138 ++--
 drivers/net/wireless/ti/wl18xx/debugfs.c           |  230 ++++--
 drivers/net/wireless/ti/wl18xx/event.c             |   13 +
 drivers/net/wireless/ti/wl18xx/event.h             |   12 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   59 +-
 drivers/net/wireless/ti/wl18xx/scan.c              |   23 +-
 drivers/net/wireless/ti/wl18xx/scan.h              |    4 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   56 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |   15 +
 drivers/net/wireless/ti/wlcore/conf.h              |   11 +-
 drivers/net/wireless/ti/wlcore/init.c              |    2 +-
 drivers/net/wireless/ti/wlcore/init.h              |    1 +
 drivers/net/wireless/ti/wlcore/main.c              |   69 +-
 drivers/net/wireless/ti/wlcore/rx.c                |    6 +
 drivers/net/wireless/ti/wlcore/scan.h              |    6 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |    3 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    5 +
 include/linux/bcma/bcma_driver_chipcommon.h        |    1 -
 193 files changed, 7123 insertions(+), 2795 deletions(-)

-- 
Kalle Valo
