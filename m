From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-06-21
Date: Tue, 21 Jun 2016 13:47:45 +0300
Message-ID: <87a8ien7hq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I hope it's ok to send two pull requests the same day, both for net and
net-next? This is targeted to 4.8 so it is for net-next.

Even though is this the first pull request for 4.8 we actually remove
more code than add, thanks to Guenter Roeck's on removing unused "phy_a=
"
support from b43. Otherwise there's not really anything standing out,
adding new chipset support to brcmfmac and ath10k, lots of fixes and th=
e
usual.

Please let me know if there any issues.

Kalle

The following changes since commit 76f21b99004ef1f16be6184678f660eab911=
b8b8:

  net: Add docbook description for 'mtu' arg to skb_gso_validate_mtu() =
(2016-06-03 22:56:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-06-21

for you to fetch changes up to 1bb57c8a5e33bcbec031ce0c629968922d5af89d=
:

  Merge ath-next from ath.git (2016-06-19 11:19:30 +0300)

----------------------------------------------------------------

wireless-drivers patches for 4.8

Major changes:

ath10k

* enable btcoex support without restarting firmware
* enable ipq4019 support using AHB bus
* add QCA9887 chipset support
* retrieve calibration data from EEPROM, currently only for QCA9887

wil6210

* add pm_notify handling

brcmfmac

* add support for the PCIE devices 43525 and 43465

----------------------------------------------------------------
Adrian Chadd (1):
      b43: don't unconditionally fall back to CCK if the rate is 6MB OF=
DM.

Amitkumar Karwar (1):
      mwifiex: inform disconnection initiator correctly.

Arend van Spriel (1):
      brcm80211: update maintainers email addresses

Arnd Bergmann (4):
      iwlegacy: avoid warning about missing braces
      wl3501_cs: avoid bogus gcc-6 warning
      rtlwifi: fix error handling in *_read_adapter_info()
      mwifiex: fix link error against sdio

Ashok Raj Nagarajan (1):
      ath10k: fix diag_read to collect data for larger memory

Bhaktipriya Shridhar (1):
      libertas: Remove create_workqueue

Bob Copeland (1):
      ath5k: fix misplaced default label in sifs switch

Christian Daudt (2):
      brcmfmac: Fix kernel oops in failed chip_attach
      brcmfmac: Fix 'did not remove int handler' warning

Eduardo Abinader (3):
      ath9k: Remove empty test condition
      ath9k: allow tx99 for ar9002 based cards
      ath9k: Proper TX99 interrupt ref count

Guenter Roeck (3):
      libertas_tf: Drop unused variable and define
      b43: Remove unused phy_a code
      b43: Completely remove support for phy_a

Hante Meuleman (2):
      brcmfmac: fix skb priority handling
      brcmfmac: add support for the PCIE devices 43525 and 43465

Heinrich Schuchardt (7):
      ath6kl: simplify logical condition
      rsi: eliminate superfluous NULL check
      mwifiex: illegal assignment
      rtlwifi: rtl8723be: avoid undefined behavior
      mwiflex: avoid possible null pointer dereference
      rtlwifi: rtl8192ee: simplify coding
      brcm80211: simplify assignment

Javier Martinez Canillas (8):
      mwifiex: only call mwifiex_sdio_probe_of() if dev has an OF node
      mwifiex: propagate sdio_enable_func() errno code in mwifiex_sdio_=
probe()
      mwifiex: propagate mwifiex_add_card() errno code in mwifiex_sdio_=
probe()
      mwifiex: consolidate mwifiex_sdio_probe() error paths
      mwifiex: use dev_err() instead of pr_err() in mwifiex_sdio_probe(=
)
      mwifiex: check if mwifiex_sdio_probe_of() fails and return error
      mwifiex: don't print an error if an optional DT property is missi=
ng
      mwifiex: use better message and error code when OF node doesn't m=
atch

Julia Lawall (2):
      ath6kl: fix typo
      mwifiex: fix typo

Kalle Valo (1):
      Merge ath-next from ath.git

Lauri Kasanen (1):
      carl9170: Clarify kconfig text

Lior David (1):
      wil6210: abort P2P search when stopping P2P device

Lucas Stach (1):
      b43: only hardcode LED behavior if SPROM doesn't encode any

Mathias Krause (1):
      mwifiex: remove misleading GFP_DMA flag in buffer allocations

Maya Erez (7):
      wil6210: fix race conditions between TX send and completion
      wil6210: guarantee safe access to rx descriptors shared memory
      wil6210: protect wil_vring_fini_tx in parallel to tx completions
      wil6210: fix dma mapping error cleanup in __wil_tx_vring_tso
      wil6210: add pm_notify handling
      wil6210: align wil log functions to wil_dbg_ratelimited implement=
ation
      wil6210: fix chan check in wil_p2p_listen

Michal Kazior (1):
      ath10k: improve tx scheduling

Mohammed Shafi Shajakhan (5):
      ath10k: reduce warning messages during rx without proper channel =
context
      ath10k: fix legacy rate packet debug messages
      ath10k: fix error while writing 'simulate_fw_crash' debugfs
      ath10k: remove duplicate and unused rx rate flags
      ath10k: fix CCK h/w rates for QCA99X0 and newer chipsets

Muhammad Falak R Wani (1):
      brcmfmac: use kmemdup

Rafa=C5=82 Mi=C5=82ecki (8):
      brcmfmac: rework function picking free BSS index
      brcmutil: add field storing control channel to the struct brcmu_c=
han
      brcmfmac: support get_channel cfg80211 callback
      brcmfmac: print errors if creating interface fails
      brcmfmac: fix setting AP channel with new firmwares
      brcmfmac: don't remove interface on link down firmware event
      brcmfmac: drop unused pm_block vif attribute
      brcmfmac: include required headers in cfg80211.h

Raja Mani (1):
      ath10k: enable ipq4019 device probe in ahb module

Rajkumar Manoharan (5):
      ath10k: fix operating irq mode for ahb device
      ath10k: remove unused phy_mode_to_band
      ath10k: update module description
      ath10k: add new ATH10K_FW_FEATURE_BTCOEX_PARAM
      ath10k: add pdev param support to enable/disable btcoex

Sven Eckelmann (2):
      ath10k: add QCA9887 chipset support
      ath10k: add board data download from target

Vasanthakumar Thiagarajan (7):
      ath10k: move rx_location_info out of struct rx_pkt_end
      ath10k: clean up growing hw checks during safe and full reset
      ath10k: define rx_ppdu_end for QCA9984
      ath10k: enable support for QCA9984
      ath10k: fix some of the macro definitions of HTT_RX_IND message
      ath10k: define an enum to enable cycle counter wraparound logic
      ath10k: fix cycle counter wraparound handling for QCA4019

Wei-Ning Huang (1):
      mwifiex: fix racing condition when downloading firmware

Wright Feng (3):
      brcmfmac: revise SDIO error message in brcmf_sdio_drivestrengthin=
it
      brcmfmac: use ndev->needed_headroom to reserve additional header =
space
      brcmfmac: change rx_seq check log from error print to debug print

 MAINTAINERS                                        |    9 +-
 drivers/net/wireless/ath/ath10k/ahb.c              |   11 +-
 drivers/net/wireless/ath/ath10k/core.c             |  105 +++-
 drivers/net/wireless/ath/ath10k/core.h             |   24 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   32 +-
 drivers/net/wireless/ath/ath10k/hif.h              |   14 +
 drivers/net/wireless/ath/ath10k/htt.h              |    6 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   36 +-
 drivers/net/wireless/ath/ath10k/hw.c               |   26 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   73 +++
 drivers/net/wireless/ath/ath10k/mac.c              |   59 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  245 +++++++-
 drivers/net/wireless/ath/ath10k/pci.h              |    6 +
 drivers/net/wireless/ath/ath10k/rx_desc.h          |   87 +--
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    3 +
 drivers/net/wireless/ath/ath10k/txrx.c             |    3 +
 drivers/net/wireless/ath/ath10k/wmi.c              |    4 +
 drivers/net/wireless/ath/ath10k/wmi.h              |    4 +
 drivers/net/wireless/ath/ath5k/pcu.c               |    2 +-
 drivers/net/wireless/ath/ath6kl/core.h             |    2 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    3 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    3 +-
 drivers/net/wireless/ath/carl9170/Kconfig          |    8 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   16 +
 drivers/net/wireless/ath/wil6210/debug.c           |   46 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |    6 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   68 ++-
 drivers/net/wireless/ath/wil6210/pm.c              |   25 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   42 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |    6 +
 drivers/net/wireless/ath/wil6210/wil_platform.h    |    4 +-
 drivers/net/wireless/broadcom/b43/Makefile         |    2 +-
 drivers/net/wireless/broadcom/b43/leds.c           |    8 +-
 drivers/net/wireless/broadcom/b43/main.c           |   31 +-
 drivers/net/wireless/broadcom/b43/phy_a.c          |  595 ------------=
--------
 drivers/net/wireless/broadcom/b43/phy_a.h          |   22 -
 drivers/net/wireless/broadcom/b43/phy_common.h     |    3 -
 drivers/net/wireless/broadcom/b43/phy_g.c          |   25 +-
 drivers/net/wireless/broadcom/b43/wa.c             |  283 +---------
 drivers/net/wireless/broadcom/b43/xmit.c           |   30 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |   47 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  164 ++++--
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    8 +-
 .../wireless/broadcom/brcm80211/brcmfmac/chip.c    |    2 +
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   26 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    1 -
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   17 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    5 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |    3 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmutil/d11.c |   18 +-
 .../broadcom/brcm80211/include/brcm_hw_ids.h       |    2 +
 .../broadcom/brcm80211/include/brcmu_d11.h         |   22 +
 drivers/net/wireless/intel/iwlegacy/3945.c         |    3 +-
 drivers/net/wireless/marvell/libertas/if_sdio.c    |    3 +-
 drivers/net/wireless/marvell/libertas/if_spi.c     |    4 +-
 drivers/net/wireless/marvell/libertas_tf/main.c    |    7 -
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |    2 +-
 drivers/net/wireless/marvell/mwifiex/init.c        |    1 +
 drivers/net/wireless/marvell/mwifiex/join.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |    6 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |    3 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |    9 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   64 ++-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |    5 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |   12 +-
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |   17 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.c   |   13 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |   20 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |   13 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   15 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |   31 +-
 83 files changed, 1256 insertions(+), 1357 deletions(-)
 delete mode 100644 drivers/net/wireless/broadcom/b43/phy_a.c
