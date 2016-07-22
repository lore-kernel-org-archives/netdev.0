From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-07-22
Date: Fri, 22 Jul 2016 17:28:44 +0300
Message-ID: <87fur1rbkz.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Brian Norris <computersforpeace@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I'm sick so I have to keep this short, but here's the last pull request
to net-next. This time there's a trivial conflict with mtd tree:

http://lkml.kernel.org/g/20160720123133.44dab209@canb.auug.org.au

We concluded with Brian (CCed) that it's best that we ask Linus to fix
this. The patches have been in linux-next for a couple of days. This
time I haven't done any merge tests so I don't know if there are any
other conflicts etc.

Please let me know if there are any problems.

Kalle

The following changes since commit 2186f6eec2739ecd3944f9278e59edf0474f=
207c:

  net: ethernet: marvell: pxa168_eth: use phy_ethtool_{get|set}_link_ks=
ettings (2016-07-17 23:22:02 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-07-22

for you to fetch changes up to cb6a115188500a448709df1f2d7698a4e1b7a099=
:

  wlcore: spi: fix build warning caused by redundant variable (2016-07-=
20 21:09:13 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.8

Major changes:

wl18xx

* add initial mesh support

bcma

* serial flash support on non-MIPS SoCs

ath10k

* enable support for QCA9888
* disable wake_tx_queue() mac80211 op for older devices to workaround
  throughput regression

ath9k

* implement temperature compensation support for AR9003+

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: fix PCIe legacy interrupt problem
      mwifiex: update command response skb length correctly

Anilkumar Kolli (2):
      ath10k: remove unused member in ath10k_hw_regs
      ath10k: enable support for QCA9888

Arend Van Spriel (2):
      brcmfmac: restore stopping netdev queue when bus clogs up
      brcmfmac: defer DPC processing during probe

Arnd Bergmann (1):
      rtlwifi: don't add include path for rtl8188ee

Ashok Raj Nagarajan (1):
      ath10k: simplify pktlog htt event processing

Ben Greear (4):
      ath10k: ensure txrx-compl-task is stopped when cleaning htt-tx
      ath10k: ensure peer_map references are cleaned up
      ath10k: Add WARN_ON if we over-write peer-map pointer.
      ath10k: Clean up peer when sta goes away.

Benjamin Berg (6):
      ath9k: Correct TSF adjustment to align the beacon time correctly
      ath9k: Handle channel context in get_/set_/reset_tsf
      ath9k: Use tsf offset helper in ath9k_hw_reset
      ath9k: Expose tsf_adjustment in mac80211 tsf getters and setters.
      ath9k: Remove some #defined constants to decrease verbosity
      ath9k: Fix beacon configuration for addition/removal of interface=
s

Bjorn Andersson (6):
      wcn36xx: Fold indication payload into message header
      wcn36xx: Change indication list lock to spinlock
      wcn36xx: Split mmio space into explicit regions
      wcn36xx: Correct DXE chip version differentiation
      wcn36xx: Fix up wcn36xx_smd_update_scan_params()
      wcn36xx: Silence error about unsupported smd event 188

Bob Copeland (1):
      ath10k: fix potential null dereference bugs

Chaehyun Lim (1):
      ath10k: remove unused <linux/semaphore.h>

Dan Kephart (1):
      ath6kl: sme_state shortcut to SME_DISCONNECTED removed

Eduardo Abinader (2):
      ath9k: return false when reading wrong eeprom offset
      ath10k: remove extra space on ath10k_update_channel_list

Eyal Reizer (1):
      wlcore: spi: add wl18xx support

=46elix Fietkau (5):
      ath9k_hw: fix spectral scan on AR9285 and newer
      ath9k_hw: fix duplicate (and partially wrong) definition of AR_CH=
0_THERM
      ath9k_hw: simplify ar9003_hw_per_calibration
      ath9k_hw: get rid of some duplicate code in calibration init
      ath9k_hw: implement temperature compensation support for AR9003+

=46lorian Fainelli (3):
      brcmfmac: Fix glob_skb leak in brcmf_sdiod_recv_chain
      brcmsmac: Free packet if dma_mapping_error() fails in dma_rxfill
      brcmsmac: Initialize power in brcms_c_stf_ss_algo_channel_get()

Kalle Valo (3):
      Merge tag 'iwlwifi-next-for-kalle-2016-07-11' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karthik D A (1):
      mwifiex: Fix request_irq() failure handling

Luciano Coelho (1):
      iwlwifi: mvm: bump MAX firmware API for mvm devices

Maital Hahn (1):
      wlcore/wl18xx: mesh: added initial mesh support for wl8

Martin Blumenstingl (6):
      ath9k: Allow configuration of LED polarity in platform data.
      ath9k: remove variable which is set but never read
      ath9k: ath9k_hw_init_macaddr should not overwrite valid MAC addre=
sses
      ath9k: remove return value from ath9k_hw_init_macaddr
      ath9k: move all ath9k_platform_data initialization into one funct=
ion
      ath9k: simplify the code-paths when not using the built-in EEPROM

Maxim Altshul (2):
      wlcore/wl18xx: Add functionality to accept TX rate per link
      wlcore: Add support for get_expected_throughput opcode

Michal Kazior (1):
      ath10k: disable wake_tx_queue for older devices

Mohammed Shafi Shajakhan (9):
      ath10k: fix crash during card removal
      ath10k: remove unneccessary WARN_ON_ONCE in rx during ACS
      ath10k: enable beacon loss detection support for 10.4
      ath10k: disable TX_STBC for tx chainmask of 1
      ath10k: fix some typo in spectral code commments
      ath10k: fix 10.4 extended peer stats update
      ath10k: add support for ath10k_sta_statistics support
      ath10k: remove debugfs support for Per STA total rx duration
      ath10k: replace warning with an error message if HTT op version i=
s unset

Pierre Le Magourou (3):
      ath6kl: Fix WLAN tethering authentication problem.
      ath6kl: Fix wrong regulatory domain disconnection.
      ath6kl: Unset IFF_LOWER_UP flag on AP mode leave.

Prasun Maiti (1):
      mwifiex: Reduce endian conversion for REG Host Commands

Rafa=C5=82 Mi=C5=82ecki (5):
      brcmfmac: respect hidden_ssid for AP interfaces
      bcma: add PCI ID for Foxconn's BCM43142 device
      bcma: allow enabling serial flash support on non-MIPS SoCs
      bcma: define ChipCommon B MII registers
      mtd: add arch dependency for MTD_BCM47XXSFLASH symbol

Reizer, Eyal (1):
      wlcore: spi: fix build warning caused by redundant variable

Sven Eckelmann (1):
      ath9k: Fix programming of minCCA power threshold

Vasanthakumar Thiagarajan (1):
      ath10k: fix possible wrong rx_busy time reporting in QCA4019

Wei Yongjun (2):
      libertas: fix non static symbol warning
      mwifiex: fix possible memory leak in mwifiex_cfg80211_start_ap()

 .../bindings/net/wireless/ti,wlcore,spi.txt        |   41 +++-
 drivers/bcma/Kconfig                               |   11 +-
 drivers/bcma/driver_chipcommon_b.c                 |    9 +-
 drivers/bcma/host_pci.c                            |    1 +
 drivers/mtd/devices/Kconfig                        |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |   28 ++-
 drivers/net/wireless/ath/ath10k/core.h             |   10 +
 drivers/net/wireless/ath/ath10k/debug.c            |   19 +-
 drivers/net/wireless/ath/ath10k/debug.h            |   11 +-
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |   74 +++---
 drivers/net/wireless/ath/ath10k/htc.h              |    1 -
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   10 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   22 +-
 drivers/net/wireless/ath/ath10k/hw.c               |   15 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   33 +--
 drivers/net/wireless/ath/ath10k/mac.c              |   67 +++++-
 drivers/net/wireless/ath/ath10k/pci.c              |   24 ++
 drivers/net/wireless/ath/ath10k/spectral.c         |    4 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    6 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   67 ++++--
 drivers/net/wireless/ath/ath10k/wmi.h              |   14 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    6 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |    9 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   18 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   32 ++-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  128 ++++++-----
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   25 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    7 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |  240 +++++++++++-=
--------
 drivers/net/wireless/ath/ath9k/common.h            |    1 +
 drivers/net/wireless/ath/ath9k/dynack.c            |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |   33 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   54 ++---
 drivers/net/wireless/ath/ath9k/hw.h                |    1 +
 drivers/net/wireless/ath/ath9k/init.c              |   54 +++--
 drivers/net/wireless/ath/ath9k/mac.h               |    4 -
 drivers/net/wireless/ath/ath9k/main.c              |   73 ++++--
 drivers/net/wireless/ath/ath9k/pci.c               |   41 ++--
 drivers/net/wireless/ath/wcn36xx/dxe.c             |   31 +--
 drivers/net/wireless/ath/wcn36xx/dxe.h             |    7 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |    4 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |   67 +++---
 drivers/net/wireless/ath/wcn36xx/smd.c             |   44 ++--
 drivers/net/wireless/ath/wcn36xx/smd.h             |    4 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    4 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   13 ++
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |   22 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    7 +-
 .../net/wireless/broadcom/brcm80211/brcmsmac/dma.c |    4 +-
 .../net/wireless/broadcom/brcm80211/brcmsmac/stf.c |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    2 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |    4 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   14 +-
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |   10 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |    9 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   28 +--
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   37 ++-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   21 +-
 .../wireless/realtek/rtlwifi/rtl8188ee/Makefile    |    2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   19 +-
 drivers/net/wireless/ti/wl18xx/tx.c                |   22 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    8 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    1 +
 drivers/net/wireless/ti/wlcore/boot.c              |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   13 +-
 drivers/net/wireless/ti/wlcore/main.c              |   44 +++-
 drivers/net/wireless/ti/wlcore/rx.c                |    7 +
 drivers/net/wireless/ti/wlcore/spi.c               |  124 ++++++++--
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   14 ++
 include/linux/ath9k_platform.h                     |    1 +
 include/linux/bcma/bcma_driver_chipcommon.h        |    3 +
 78 files changed, 1178 insertions(+), 644 deletions(-)

--=20
Kalle Valo
