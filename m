From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-11-25
Date: Fri, 25 Nov 2016 11:39:49 +0200
Message-ID: <8760nbaoey.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55236 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753119AbcKYJj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:39:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for 4.10. ath9k has now been converted to use
mac80211 intermediate software queues to fix bufferbloat problems. rsi
has become active again and latevy mwifiex has been getting a _lot_ of
love.

I'm not expecting to see any problems with this pull request. When you
pull git will do lots of automerging but at least I didn't see any
conflicts. Please let me know if you have any problems.

Kalle

The following changes since commit 6edf10173a1feb1078f2fc8c655baf9614e83493:

  devlink: Prevent port_type_set() callback when it's not needed (2016-10-2=
6 17:30:32 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2016-11-25

for you to fetch changes up to 159a55a64d44acbbd6f0d8f3c082e628d6d75670:

  rt2800: disable CCK rates on HT (2016-11-23 17:38:53 +0200)

----------------------------------------------------------------
wireless-drivers-next patches for 4.10

Major changes:

iwlwifi

* finalize and enable dynamic queue allocation
* use dev_coredumpmsg() to prevent locking the driver
* small fix to pass the AID to the FW
* use FW PS decisions with multi-queue

ath9k

* add device tree bindings
* switch to use mac80211 intermediate software queues to reduce
  latency and fix bufferbloat

wl18xx

* allow scanning in AP mode

----------------------------------------------------------------
Amitkumar Karwar (6):
      mwifiex: prevent register accesses after host is sleeping
      mwifiex: report error to PCIe for suspend failure
      mwifiex: Fix NULL pointer dereference in skb_dequeue()
      mwifiex: add memrw command information in README
      mwifiex: ignore calibration data failure
      mwifiex: remove redundant pdev check in suspend/resume handlers

Anilkumar Kolli (1):
      ath10k: add cc_wraparound type for QCA9888 and QCA9884

Arnd Bergmann (2):
      wireless: fix bogus maybe-uninitialized warning
      cw1200: fix bogus maybe-uninitialized warning

Aviya Erenfeld (1):
      iwlwifi: mvm: use dev_coredumpsg()

Bartosz Markowski (1):
      ath10k: add platform regulatory domain support

Benjamin Berg (1):
      ath10k: allow setting coverage class

Brian Norris (8):
      mwifiex: don't do unbalanced free()'ing in cleanup_if()
      mwifiex: resolve races between async FW init (failure) and device rem=
oval
      mwifiex: don't pretend to resume while remove()'ing
      mwifiex: resolve suspend() race with async FW init failure
      mwifiex: usb: handle HS failures
      mwifiex: sdio: don't check for NULL sdio_func
      mwifiex: stop checking for NULL drvata/intfdata
      mwifiex: pcie: stop checking for NULL adapter->card

Colin Ian King (1):
      ath9k_htc: fix minor mistakes in dev_err messages

Emmanuel Grumbach (1):
      iwlwifi: mvm: tell the firmware about the AID of the peer

James Minor (4):
      ath6kl: fix busreqs so they can be reused when sg is cleaned up
      ath6kl: after cleanup properly reflect that sg is disabled
      ath6kl: configure SDIO when power is reapplied
      wlcore: Allow scans when in AP mode

Jiri Slaby (1):
      p54: memset(0) whole array

Johannes Berg (1):
      iwlwifi: mvm: use firmware station PM notification for AP_LINK_PS

Johannes Thumshirn (1):
      cw1200: Don't leak memory if krealloc failes

Kalle Valo (3):
      Merge tag 'iwlwifi-next-for-kalle-2016-10-25-2' of git://git.kernel.o=
rg/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karthik D A (2):
      mwifiex: vendor_ie length check for parse WMM IEs
      mwifiex: fix p2p device doesn't find in scan problem

Larry Finger (9):
      rtlwifi: rtl8192de: Remove address of Free Software Foundation
      rtlwifi: rtl8192se: Remove address of Free Software Foundation
      rtlwifi: rtl8192ce: Remove address of Free Software Foundation
      rtlwifi: rtl8192cu: Remove address of Free Software Foundation
      rtlwifi: rtl8723ae: Remove address of Free Software Foundation
      rtlwifi: rtl8188ee: Remove address of Free Software Foundation
      rtlwifi: rtl8192c: Remove address of Free Software Foundation
      rtlwifi: Remove address of Free Software Foundation
      ssb: Fix error routine when fallback SPROM fails

Liad Kaufman (5):
      iwlwifi: mvm: update txq metadata to current owner
      iwlwifi: mvm: fix reserved txq freeing
      iwlwifi: mvm: support MONITOR vif in DQA mode
      iwlwifi: mvm: fix dqa deferred frames marking
      iwlwifi: mvm: enable dynamic queue allocation mode

Maharaja Kennadyrajan (1):
      ath10k: provide provision to get Transmit Power Control stats for 10.4

Martin Blumenstingl (3):
      Documentation: dt: net: add ath9k wireless device binding
      ath9k: add a helper to get the string representation of ath_bus_type
      ath9k: parse the device configuration from an OF node

Mathias Kresin (1):
      rt2x00: add support for mac addr from device tree

Maxim Altshul (2):
      wlcore: Pass win_size taken from ieee80211_sta to FW
      wlcore: Add RX_BA_WIN_SIZE_CHANGE_EVENT event

Miaoqing Pan (1):
      ath9k: change entropy formula for easier understanding

Michal Kazior (1):
      ath: export alpha2 helper

Mohammed Shafi Shajakhan (4):
      ath10k: cleanup calling ath10k_htt_rx_h_unchain
      ath10k: fix failure to send NULL func frame for 10.4
      ath10k: clean up HTT tx buffer allocation and free
      ath10k: remove extraneous error message in tx alloc

Nicolas Iooss (1):
      ath10k: use the right length of "background"

Prameela Rani Garnepudi (2):
      rsi: Fix memory leak in module unload
      rsi: Host to device command frame vap_capabilites modified with new f=
ield vap status

Rafa=C5=82 Mi=C5=82ecki (2):
      brcmfmac: proto: add callback for queuing TX data
      brcmfmac: print name of connect status event

Rajat Jain (4):
      mwifiex: report wakeup for wowlan
      mwifiex: Allow mwifiex early access to device structure
      mwifiex: Introduce mwifiex_probe_of() to parse common properties
      mwifiex: Enable WoWLAN for both sdio and pcie

Ricky Liang (1):
      mwifiex: fix memory leak in mwifiex_save_hidden_ssid_channels()

Sara Sharon (1):
      iwlwifi: mvm: assign cab queue to the correct station

Sharon Dvir (1):
      iwlwifi: pcie: give a meaningful name to interrupt request

Shengzhen Li (3):
      mwifiex: add power save parameters in hs_cfg cmd
      mwifiex: check tx_hw_pending before downloading sleep confirm
      mwifiex: complete blocked power save handshake in main process

Stanislaw Gruszka (9):
      rt2800: correctly report MCS TX parameters
      rt2800usb: do not wipe out USB_DMA_CFG settings
      rt2800: OFDM rates are mandatory
      rt2800: do not overwrite WPDMA_GLO_CFG_WP_DMA_BURST_SIZE
      rt2800: correct AUTO_RSP_CFG
      rt2800: correct TX_SW_CFG1 for 5592
      rt2800: use RTS/CTS protection instead of CTS-to-self
      rt2800: tune *_PROT_CFG parameters
      rt2800: disable CCK rates on HT

Toke H=C3=B8iland-J=C3=B8rgensen (1):
      ath9k: Switch to using mac80211 intermediate software queues.

Vasanthakumar Thiagarajan (1):
      ath10k: fix kernel panic due to race in accessing arvif list

Vishal Thanki (1):
      rt2x00: Fix incorrect usage of CONFIG_RT2X00_LIB_USB

Vittorio Gambaletta (VittGam) (1):
      ath9k: Really fix LED polarity for some Mini PCI AR9220 MB92 cards.

Wei Yongjun (2):
      mwifiex: fix missing destroy_workqueue() on error in mwifiex_add_virt=
ual_intf()
      rtlwifi: Use dev_kfree_skb_irq instead of kfree_skb

Wright Feng (1):
      brcmfmac: update beacon IE after bss up and clear when AP stopped

Xinming Hu (4):
      mwifiex: update tx_pkts_queued for requeued packets
      mwifiex: fix command timeout problem seen in stress tests
      mwifiex: parse device tree node for PCIe
      mwifiex: reset card->adapter during device unregister

 .../{marvell-sd8xxx.txt =3D> marvell-8xxx.txt}       |    8 +-
 .../devicetree/bindings/net/wireless/qca,ath9k.txt |   48 +++
 drivers/net/wireless/ath/ath.h                     |    6 +
 drivers/net/wireless/ath/ath10k/core.c             |   13 +
 drivers/net/wireless/ath/ath10k/core.h             |   20 +-
 drivers/net/wireless/ath/ath10k/debug.h            |   22 ++
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   12 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   79 +++--
 drivers/net/wireless/ath/ath10k/hw.c               |  142 ++++++++
 drivers/net/wireless/ath/ath10k/hw.h               |   28 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  140 +++++++-
 drivers/net/wireless/ath/ath10k/spectral.c         |    2 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   54 +++-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   15 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    8 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   27 +-
 drivers/net/wireless/ath/ath9k/channel.c           |    2 -
 drivers/net/wireless/ath/ath9k/debug.c             |   14 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 -
 drivers/net/wireless/ath/ath9k/debug_sta.c         |    4 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    6 +-
 drivers/net/wireless/ath/ath9k/init.c              |   44 ++-
 drivers/net/wireless/ath/ath9k/main.c              |    9 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    7 +-
 drivers/net/wireless/ath/ath9k/rng.c               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  338 ++++++++--------=
----
 drivers/net/wireless/ath/main.c                    |    7 +
 drivers/net/wireless/ath/regd.c                    |    3 +-
 drivers/net/wireless/ath/regd.h                    |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   12 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |    4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.h    |    2 +
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |   15 +-
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |    6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/proto.c   |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/proto.h   |    9 +
 drivers/net/wireless/intel/ipw2x00/libipw_rx.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |    2 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   26 ++
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  100 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   86 ++++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |    3 +
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   37 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    1 +
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   29 +-
 .../net/wireless/intersil/hostap/hostap_80211_rx.c |    2 +-
 drivers/net/wireless/intersil/p54/fwio.c           |    2 +-
 drivers/net/wireless/marvell/mwifiex/README        |   23 ++
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   12 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |    5 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   10 +
 drivers/net/wireless/marvell/mwifiex/init.c        |    1 +
 drivers/net/wireless/marvell/mwifiex/main.c        |  113 +++++--
 drivers/net/wireless/marvell/mwifiex/main.h        |   40 ++-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  166 +++++-----
 drivers/net/wireless/marvell/mwifiex/pcie.h        |    2 +
 drivers/net/wireless/marvell/mwifiex/scan.c        |    4 +
 drivers/net/wireless/marvell/mwifiex/sdio.c        |  153 +++------
 drivers/net/wireless/marvell/mwifiex/sdio.h        |    9 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   49 +--
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |    8 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |   60 ++--
 drivers/net/wireless/marvell/mwifiex/usb.h         |    2 +
 drivers/net/wireless/marvell/mwifiex/wmm.c         |   31 +-
 drivers/net/wireless/ralink/rt2x00/rt2400pci.c     |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2500pci.c     |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   67 ++--
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    1 +
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   19 +-
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |    5 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |    2 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |    4 -
 drivers/net/wireless/realtek/rtlwifi/pci.h         |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8188ee/fw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8188ee/led.c   |    4 -
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.c  |    4 -
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.h  |    4 -
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.h  |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192c/main.c   |    4 -
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c |    4 -
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.h |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/def.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/dm.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/led.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/led.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/reg.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/rf.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/rf.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/table.c |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/table.h |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/def.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/dm.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/led.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/led.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/phy.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/phy.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/reg.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/rf.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/rf.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/table.c |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/table.h |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/def.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/dm.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/led.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/led.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/reg.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/rf.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/rf.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/table.c |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/table.h |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/def.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/dm.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/fw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/fw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/led.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/led.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/reg.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/rf.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/rf.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/table.c |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/table.h |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.c   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.h   |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8723ae/dm.h    |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8723ae/fw.h    |    4 -
 .../realtek/rtlwifi/rtl8723ae/hal_bt_coexist.h     |    4 -
 .../net/wireless/realtek/rtlwifi/rtl8723ae/led.c   |    4 -
 drivers/net/wireless/realtek/rtlwifi/usb.c         |    4 -
 drivers/net/wireless/realtek/rtlwifi/usb.h         |    4 -
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   19 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |    5 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                |    9 +-
 drivers/net/wireless/st/cw1200/wsm.c               |   24 +-
 drivers/net/wireless/ti/wl18xx/event.c             |   28 ++
 drivers/net/wireless/ti/wl18xx/event.h             |    1 +
 drivers/net/wireless/ti/wl18xx/main.c              |    3 +-
 drivers/net/wireless/ti/wlcore/acx.c               |    5 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    3 +-
 drivers/net/wireless/ti/wlcore/main.c              |    8 +-
 drivers/ssb/pci.c                                  |    1 +
 net/wireless/lib80211_crypt_tkip.c                 |    2 +-
 189 files changed, 1607 insertions(+), 1152 deletions(-)
 rename Documentation/devicetree/bindings/net/wireless/{marvell-sd8xxx.txt =
=3D> marvell-8xxx.txt} (91%)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/qca,ath9=
k.txt
