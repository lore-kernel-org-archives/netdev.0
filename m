From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-02-09
Date: Thu, 09 Feb 2017 16:08:25 +0200
Message-ID: <87bmubjw2u.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

another pull request for net-next. If the merge window starts on Sunday
this would be the last pull request from me with new features. But if it
doesn't open, I'm planning to send one more next week.

Please let me know if there any problems.

Kalle


The following changes since commit 62e13097c46c69dbd7544ab2cd585ccf48f360a4:

  net: phy: broadcom: rehook BCM54612E specific init (2017-02-01 14:20:20 -=
0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-02-09

for you to fetch changes up to cbda794cf1bb2f4a2e75e11fda1f89457169772e:

  Merge tag 'iwlwifi-next-for-kalle-2017-02-08' of git://git.kernel.org/pub=
/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2017-02-08 21:28:36 +0200)

----------------------------------------------------------------
wireless-drivers-next patches for 4.11

Mostly smaller changeds and fixes all over, nothing really major
standing out.

Major changes:

iwlwifi

* work on support for new A000 devices continues
* fix 802.11w, which was failing to due an IGTK bug

ath10k

* add debugfs file peer_debug_trigger for debugging firmware

----------------------------------------------------------------
Ashok Raj Nagarajan (1):
      ath10k: fix reading sram contents for QCA4019

Avraham Stern (1):
      iwlwifi: mvm: Fix CSA received immediately after association

Beni Lev (1):
      iwlwifi: mvm: Use aux queue for offchannel frames in dqa

Bjorn Andersson (1):
      wcn36xx: Implement cancel_hw_scan

Emmanuel Grumbach (6):
      iwlwifi: mvm: fix PS-Poll enablement
      iwlwifi: mvm: use the PROBE_RESP_QUEUE to send deauth to unknown stat=
ion
      iwlwifi: pcie: don't increment / decrement a bool
      iwlwifi: make RTPM depend on EXPERT
      iwlwifi: dvm: don't call << operator with a negative value
      iwlwifi: mvm: don't call << operator with a negative value

Felix Fietkau (3):
      ath9k: rename tx_complete_work to hw_check_work
      ath9k_hw: check if the chip failed to wake up
      ath9k: fix race condition in enabling/disabling IRQs

Ganapathi Bhat (1):
      mwifiex: Avoid skipping WEP key deletion for AP

Golan Ben Ami (2):
      iwlwifi: pcie: Re-configure IVAR table after stop device
      iwlwifi: pcie: set STATUS_RFKILL immediately after interrupt

Golan Ben-Ami (2):
      iwlwifi: mvm: support v2 of mfuart load notification
      iwlwifi: mvm: avoid exceeding the allowed print length

Goodstein, Mordechay (1):
      iwlwifi: mvm: avoid race condition in ADD_STA.

Gregory Greenman (1):
      iwlwifi: mvm: fix a print of NSS for HT rate

Haim Dreyfuss (3):
      iwlwifi: pcie: move msix conf functions above other functions
      iwlwifi: pcie: separate between SW and HW MSIX configuration
      iwlwifi: pcie: re-configure IVAR table after suspend-resume

Ilan Peer (1):
      iwlwifi: mvm: Fix removal of IGTK

Johannes Berg (10):
      iwlwifi: mvm: reduce usage of IEEE80211_SKB_CB()
      iwlwifi: mvm: fix D3 replay counter value
      iwlwifi: mvm: set AID to firmware only for associated stations
      iwlwifi: mvm: overwrite skb info later
      iwlwifi: mvm/pcie: adjust A-MSDU tx_cmd length in PCIe
      iwlwifi: mvm: align copy-break SKB payload for MQ RX
      iwlwifi: pcie: fix another RF-kill race
      mwifiex: don't include mac80211.h
      wil6210: include moduleparam.h
      ath10k: select WANT_DEV_COREDUMP

Kalle Valo (6):
      Merge tag 'iwlwifi-next-for-kalle-2017-02-06' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      ath10k: prefer unsigned int over just unsigned
      ath10k: use names in function definition arguments
      ath10k: few whitespace fixes
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge tag 'iwlwifi-next-for-kalle-2017-02-08' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next

Larry Finger (10):
      rtlwifi: btcoexist: Change logging in halbtc8192e2ant.c
      rtlwifi: rtl8821ae: Fix typo in symbol for bandwidth numbers
      rtlwifi: btcoexist: Convert halbtc8192e2ant.c to use standard debuggi=
ng
      rtlwifi: btcoexist: Convert halbtc8723b1ant.c to use standard debuggi=
ng
      rtlwifi: btcoexist: Convert halbtc8723b2ant.c to use standard debuggi=
ng
      rtlwifi: btcoexist: Convert halbtc8821a1ant.c to use standard debuggi=
ng
      rtlwifi: btcoexist: Convert halbtc8821a2ant.c to use standard debuggi=
ng
      rtlwifi: btcoexist: Convert halbtcoutsrc.c to use standard debugging
      rtlwifi: rtl8192c-common: Fix "BUG: KASAN:
      rtlwifi: Move items out of rtl_pci_priv and rtl_usb_priv

Liad Kaufman (1):
      iwlwifi: mvm: release static queues on bcast release

Luca Coelho (2):
      iwlwifi: remove unnecessary argument to iwl_drv_start()
      iwlwifi: remove unnecessary cfg element in iwl_drv

Maharaja Kennadyrajan (1):
      ath10k: add debugfs support to get per peer tids log via tracing

Ping-Ke Shih (10):
      rtlwifi: Fix programing CAM content sequence.
      rtlwifi: Set retry limit depends on vif type.
      rtlwifi: Add a new enumeration value to btc_set_type
      rtlwifi: btcoexist: Add vendor definition for new btcoexist
      rtlwifi: rtl8723be: btcoexist: Add single_ant_path
      rtlwifi: move btcoex's ant_num declaration
      rtlwifi: rtl8723be: btcoex: add package_type function to btcoex
      rtlwifi: btcoex: move bt_type declaration
      rtlwifi: rtl8723be: fix ant_sel code
      rtlwifi: Add work queue for c2h cmd.

Rafa=C5=82 Mi=C5=82ecki (6):
      brcmfmac: check brcmf_bus_get_memdump result for error
      brcmfmac: be more verbose when PSM's watchdog fires
      brcmfmac: use wiphy_read_of_freq_limits to respect limits from DT
      brcmfmac: merge two brcmf_err macros into one
      brcmfmac: switch to C function (__brcmf_err) for printing errors
      brcmfmac: merge two remaining brcmf_err macros

Sara Sharon (14):
      iwlwifi: mvm: support unification of INIT and RT images
      iwlwifi: mvm: cleanup incorrect and redundant define
      iwlwifi: mvm: support new statistics APIs
      iwlwifi: mvm: support new scan API
      iwlwifi: mvm: always free inactive queue when moving ownership
      iwlwifi: mvm: support new alive notification
      iwlwifi: mvm: synchronize firmware DMA paging memory
      iwlwifi: pcie: fix the set of DMA memory mask
      iwlwifi: mvm: fix pending frame counter calculation
      iwlwifi: mvm: cleanup iwl_mvm_tx_mpdu a bit
      iwlwifi: support two phys for a000 devices
      iwlwifi: mvm: support new beacon template command
      iwlwifi: mvm: fix references to first_agg_queue in DQA mode
      iwlwifi: mvm: fix reorder timer re-arming

Stanislaw Gruszka (6):
      rt2x00: avoid introducing a USB dependency in the rt2x00lib module
      rt2x00usb: do not anchor rx and tx urb's
      rt2x00usb: fix anchor initialization
      rt61pci: use entry directly
      rt2x00: call entry directly in rt2x00_dump_frame
      rt2x00: remove queue_entry from skbdesc

Tamizh chelvam (1):
      ath10k: fix boot failure in UTF mode/testmode

Waldemar Rymarkiewicz (1):
      ath10k: remove unneeded semicolon

 drivers/net/wireless/ath/ath10k/Kconfig            |    1 +
 drivers/net/wireless/ath/ath10k/ahb.c              |   23 +
 drivers/net/wireless/ath/ath10k/ce.c               |    6 +-
 drivers/net/wireless/ath/ath10k/core.c             |   14 +-
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |   65 ++
 drivers/net/wireless/ath/ath10k/htt.h              |    6 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    2 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   53 +-
 drivers/net/wireless/ath/ath10k/pci.h              |    5 +
 drivers/net/wireless/ath/ath10k/wmi.h              |    3 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    4 +
 drivers/net/wireless/ath/ath9k/init.c              |    2 +
 drivers/net/wireless/ath/ath9k/link.c              |   46 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   44 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |   37 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 -
 drivers/net/wireless/ath/wcn36xx/main.c            |   25 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |    1 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    1 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    6 +
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   16 +
 .../wireless/broadcom/brcm80211/brcmfmac/debug.c   |   35 +-
 .../wireless/broadcom/brcm80211/brcmfmac/debug.h   |   24 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig         |    7 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   30 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    3 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   25 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.h       |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |    4 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |    7 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |  106 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-stats.h  |   29 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   29 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   90 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |    4 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  338 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  105 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   39 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |   44 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   70 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   14 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |  230 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  234 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  129 +--
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   16 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   17 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    4 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   12 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  251 +++--
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   23 +-
 drivers/net/wireless/marvell/mwifiex/decl.h        |    2 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |    2 -
 drivers/net/wireless/ralink/rt2x00/rt2400pci.c     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2500pci.c     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   27 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.c   |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.h   |    2 -
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |   22 +-
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |    2 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        |   93 ++
 drivers/net/wireless/realtek/rtlwifi/base.h        |    3 +
 .../wireless/realtek/rtlwifi/btcoexist/Makefile    |    6 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    | 1082 ++++++++++------=
----
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  827 ++++++++-------
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |  993 +++++++++-------=
--
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  898 ++++++++--------
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 1075 ++++++++++------=
---
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |   36 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |   20 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |   16 -
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.h   |    5 +-
 drivers/net/wireless/realtek/rtlwifi/cam.c         |    6 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |   21 +-
 drivers/net/wireless/realtek/rtlwifi/efuse.c       |    5 +-
 drivers/net/wireless/realtek/rtlwifi/efuse.h       |    1 +
 drivers/net/wireless/realtek/rtlwifi/pci.c         |    7 +
 drivers/net/wireless/realtek/rtlwifi/pci.h         |    4 +-
 drivers/net/wireless/realtek/rtlwifi/ps.c          |    3 +
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |   14 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/led.c   |   19 +-
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.c  |  143 ++-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |  166 ++-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/led.c   |   19 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/led.c   |   17 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/led.c   |   19 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.h    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/led.c   |   14 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |    1 +
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/led.c   |   19 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/led.c   |   19 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |   18 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.h    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   50 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/led.c   |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    1 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |   18 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.h    |    3 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/led.c   |   24 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |    1 +
 drivers/net/wireless/realtek/rtlwifi/usb.h         |    2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   33 +-
 122 files changed, 4689 insertions(+), 3541 deletions(-)
