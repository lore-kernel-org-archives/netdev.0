From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-12-01
Date: Thu, 01 Dec 2016 20:33:37 +0200
Message-ID: <877f7jsdmm.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's another pull request for net-next. Nothing special to mention
about, the details are in the signed tag below.

This time there's a trivial conflict in
drivers/net/wireless/ath/ath10k/mac.c:

<<<<<<< HEAD
	ieee80211_hw_set(ar->hw, SUPPORTS_TX_FRAG);
=======
	ieee80211_hw_set(ar->hw, REPORTS_LOW_ACK);
>>>>>>> d5fb3a138048798ce4cc4b4ced47d07d1794c577

We want to have both flags enabled in ath10k.

I'm planning to submit at least one more pull request, if Linus gives us
one more week I might send even two. For example there are patches to
convert wcn36xx to use the real SMD bus subsystem but they depend on few
arm-soc patches. I'll send a separate email about that, they are not
part of this pull request.

Please let me know if there are any problems.

Kalle

The following changes since commit 159a55a64d44acbbd6f0d8f3c082e628d6d75670:

  rt2800: disable CCK rates on HT (2016-11-23 17:38:53 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-12-01

for you to fetch changes up to d5fb3a138048798ce4cc4b4ced47d07d1794c577:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git (2016-12-01 15:09:14 +0200)

----------------------------------------------------------------

wireless-drivers-next patches for 4.10

Major changes:

rsi

* filter rx frames
* configure tx power
* make it possible to select antenna
* support 802.11d

brcmfmac

* cleanup of scheduled scan code
* support for bcm43341 chipset with different chip id
* support rev6 of PCIe device interface

ath10k

* add spectral scan support for QCA6174 and QCA9377 families
* show used tx bitrate with 10.4 firmware

wil6210

* add power save mode support
* add abort scan functionality
* add support settings retry limit for short frames

bcma

* add Dell Inspiron 3148

----------------------------------------------------------------
Anilkumar Kolli (2):
      ath10k: add per peer htt tx stats support for 10.4
      ath10k: add support for per sta tx bitrate

Anthony Romano (2):
      mt7601u: wait for clear rxq when stopping mac
      ath9k_htc: don't use HZ for usb msg timeouts

Arend Van Spriel (11):
      brcmfmac: add support for 43341 chip
      brcmfmac: move pno helper functions in separate source file
      brcmfmac: fix handling ssids in .sched_scan_start() callback
      brcmfmac: change prototype for brcmf_do_escan()
      brcmfmac: make internal escan more generic
      brcmfmac: split up brcmf_pno_config() function
      brcmfmac: move scheduled scan activation to pno source file
      brcmfmac: use provided channels for scheduled scan
      brcmfmac: remove restriction from .sched_scan_start() callback
      brcmfmac: use requested scan interval in scheduled scan
      brcmfmac: fix scheduled scan result handling for newer chips

Barry Day (1):
      rtl8xxxu: tx rate reported before set

Ben Greear (1):
      ath10k: wmi-alloc-chunk should use DMA_BIDIRECTIONAL

Bhumika Goyal (1):
      ath9k: constify ath_bus_ops structure

Brian Norris (3):
      mwifiex: cleanup wake-IRQ handling if suspend fails
      mwifiex: avoid double-disable_irq() race
      mwifiex: pcie: implement timeout loop for FW programming doorbell

Dedy Lansky (1):
      wil6210: fix net queue stop/wake

Erik Stromdahl (1):
      ath10k: fix TLV set regdomain command

Franky Lin (1):
      brcmfmac: add pcie host dongle interface rev6 support

Geliang Tang (1):
      ath5k: drop duplicate header vmalloc.h

Jes Sorensen (7):
      rtl8xxxu: Fix memory leak in handling rxdesc16 packets
      rtl8xxxu: Fix big-endian problem reporting mactime
      rtl8xxxu: Fix rtl8723bu driver reload issue
      rtl8xxxu: Fix rtl8192eu driver reload issue
      rtl8xxxu: Obtain RTS rates from mac80211
      rtl8xxxu: Pass tx_info to fill_txdesc in order to have access to retry count
      rtl8xxxu: Work around issue with 8192eu and 8723bu devices not reconnecting

Jiri Slaby (1):
      bcma: add Dell Inspiron 3148

Kalle Valo (1):
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karthik D A (1):
      mwifiex: Disable adhoc feature based on firmware capability

Kirtika Ruchandani (7):
      mwifiex: Removed unused mwifiex_private* 'priv' variable
      mwifiex: Remove unused 'chan_num' variable
      mwifiex: Remove unused 'sta_ptr' variable
      mwifiex: Remove unused 'adapter'variable
      mwifiex: Remove unused 'pm_flag' variable
      mwifiex: Removed unused 'pkt_type' variable
      mwifiex: Remove unused 'bcd_usb' variable

Larry Finger (1):
      rtlwifi: Fix enter/exit power_save

Lior David (6):
      wil6210: fix deadlock when using fw_no_recovery option
      wil6210: align to latest auto generated wmi.h
      wil6210: support NL80211_ATTR_WIPHY_RETRY_SHORT
      wil6210: delay remain on channel when scan is active
      wil6210: add debugfs blobs for UCODE code and data
      wil6210: align to latest auto generated wmi.h

Manoharan, Rajkumar (1):
      ath10k: fix monitor vdev for receiving other bss frames

Matthias Schiffer (1):
      ath9k: fix ath9k_hw_gpio_get() to return 0 or 1 on success

Maya Erez (3):
      wil6210: add support for power save enable / disable
      wil6210: add support for abort scan
      wil6210: validate wil_pmc_alloc parameters

Miaoqing Pan (1):
      ath9k: fix NULL pointer dereference

Michal Kazior (2):
      ath10k: fix null deref on wmi-tlv when trying spectral scan
      ath10k: add spectral scan support to wmi-tlv

Mohammed Shafi Shajakhan (2):
      ath10k: fix soft lockup during firmware crash/hw-restart
      ath10k: fix Tx DMA alloc failure during continuous wifi down/up

Pedersen, Thomas (2):
      ath10k: implement offset_tsf ieee80211_op
      ath10k: remove set/get_tsf ieee80211_ops

Prameela Rani Garnepudi (4):
      rsi: Add support to filter rx frames
      rsi: Add support for configuring tx power
      rsi: Add support for antenna selection
      rsi: Add support for 802.11d

Rajkumar Manoharan (1):
      ath10k: advertize hardware packet loss mechanism

Tobias Regnery (1):
      brcmsmac: fix array out-of-bounds access in qm_log10

Wei Yongjun (1):
      rtl8xxxu: Fix non static symbol warning

Zefir Kurtisi (1):
      ath9k: feed only active spectral / dfs-detector

 drivers/bcma/host_pci.c                            |    1 +
 drivers/net/wireless/ath/ath10k/core.c             |    8 +-
 drivers/net/wireless/ath/ath10k/core.h             |   24 +
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |   13 +
 drivers/net/wireless/ath/ath10k/htt.c              |    2 +
 drivers/net/wireless/ath/ath10k/htt.h              |   31 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  125 +++++
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   54 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   51 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |    6 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   77 ++-
 drivers/net/wireless/ath/ath10k/wmi.c              |    8 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   18 +-
 drivers/net/wireless/ath/ath5k/debug.c             |    1 -
 drivers/net/wireless/ath/ath9k/ahb.c               |    2 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c   |    8 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    9 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   17 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  129 ++++-
 drivers/net/wireless/ath/wil6210/main.c            |  100 ++--
 drivers/net/wireless/ath/wil6210/netdev.c          |    2 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |  160 ++++--
 drivers/net/wireless/ath/wil6210/pmc.c             |   55 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  110 +++-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   25 +-
 drivers/net/wireless/ath/wil6210/wil_crash_dump.c  |    6 +
 drivers/net/wireless/ath/wil6210/wmi.c             |  160 +++++-
 drivers/net/wireless/ath/wil6210/wmi.h             |  586 ++++++++++++++++----
 .../wireless/broadcom/brcm80211/brcmfmac/Makefile  |    3 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |   10 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  381 +++++--------
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    4 +-
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |   23 +
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |   38 +-
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.h  |    4 +
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |  171 +++---
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.c |  242 ++++++++
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.h |   40 ++
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    1 +
 .../broadcom/brcm80211/brcmsmac/phy/phy_qmath.c    |    5 +-
 .../broadcom/brcm80211/include/brcm_hw_ids.h       |    1 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   12 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |    1 +
 drivers/net/wireless/marvell/mwifiex/main.c        |    3 -
 drivers/net/wireless/marvell/mwifiex/main.h        |    9 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   17 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |    8 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    6 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   38 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |    3 +-
 drivers/net/wireless/mediatek/mt7601u/init.c       |   14 +-
 drivers/net/wireless/mediatek/mt7601u/regs.h       |    3 +
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   31 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |   10 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |    4 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  122 ++--
 drivers/net/wireless/realtek/rtlwifi/base.c        |    8 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |    9 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   14 +-
 drivers/net/wireless/realtek/rtlwifi/ps.c          |   36 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |  156 +++++-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |  129 ++++-
 drivers/net/wireless/rsi/rsi_main.h                |    4 +
 drivers/net/wireless/rsi/rsi_mgmt.h                |   23 +-
 66 files changed, 2581 insertions(+), 794 deletions(-)
 create mode 100644 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pno.c
 create mode 100644 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pno.h
