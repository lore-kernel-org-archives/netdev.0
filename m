From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-06-11
Date: Tue, 11 Jun 2013 15:05:48 -0400
Message-ID: <20130611190546.GE3196@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59940 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3FKTHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 15:07:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This pull request is intended for the 3.11 stream...

One big highlight is the cw1200 driver the ST-E CW1100 & CW1200
WLAN chipsets.  This one has been lingering for a while, lacking
some review comments.  Once started getting pulled into linux-next,
it got a bit more attention and a number of improvements were made
over the initial cut.  No doubt there will be more changes ahead,
but I think it is looking alright at this point.

Along with that, there is the usual flurry of updates to the mac80211
core and the iwlwifi, mwifiex, ath9k, rt2x00, wil6210, and other
drivers.  A few of the highlights are some rt2x00 refactoring/cleanup
by Gabor Juhos, some rt2800 hardware support enhancements by Stanislaw
Gruszka, some iwlwifi power management updates from Alexander Bondar,
some enhanced bcma SPROM support from Rafa=C5=82 Mi=C5=82ecki, and a variety
of other things here and there.

Please let me know if there are problems!

John

---

The following changes since commit 45203a3b380cee28f570475c0d28c169f908c209:

  net_sched: add 64bit rate estimators (2013-06-11 02:51:03 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 3899ba90a4ab2f3cab8e0f91a76c14ff131c8293:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-06-11 14:48:32 -0400)

----------------------------------------------------------------

Alexander Bondar (8):
      mac80211: enable power save only if DTIM period is available
      iwlwifi: mvm: Add number of DTIMs to skip
      iwlwifi: mvm: configure power management in D3
      iwlwifi: mvm: Add beacon abort enablement
      iwlwifi: mvm: Change number of DTIMs to skip semantics
      iwlwifi: mvm: add debugfs for powersave
      iwlwifi: mvm: Change location of vif_count verification for PM
      iwlwifi: mvm: enable PM always in unassociated mode

Amitkumar Karwar (12):
      mwifiex: rename mwifiex_free_adapter() routine in init.c
      mwifiex: scan delay timer cleanup in unload path
      mwifiex: remove global user_scan_cfg variable
      mwifiex: add calibration data download feature
      mwifiex: use u32 variables for SDIO read/write port bitmap
      mwifiex: store SDIO chip specific information in separate structure
      mwifiex: replace unnecessary u32 variables with u8 in sdio.c
      mwifiex: code rearrangement in mwifiex_get_rd_port()
      mwifiex: do port calculations separately
      mwifiex: define a macro for MPA base address
      mwifiex: remove unnecessary macros in sdio.h
      mwifiex: code rearrangement in multiport aggregation path

Andy Shevchenko (1):
      mwifiex: dump small buffers with help of %*ph

Ashok Nagarajan (2):
      mac80211: Move mesh estab_plinks outside mesh_stats debug group
      {cfg,mac}80211: move mandatory rates calculation to cfg80211

Avinash Patil (3):
      mwifiex: avoid deleting all stations during mwifiex_del_sta_entry()
      mwifiex: add del_station handler
      mwifiex: replace spin_lock_irqsave with spin_lock and fix warn_on

Bing Zhao (1):
      mwifiex: abort remaining scan commands when association started

Colleen Twitty (2):
      cfg80211: Userspace may inform kernel of mesh auth method.
      mac80211: enable Auth Protocol Identifier on mesh config.

Dan Carpenter (2):
      cw1200: read beyond end of array in debug code
      cw1200: handle allocation failure in wsm_event_indication()

Emmanuel Grumbach (14):
      iwlwifi: move BUILD_RAxTID to transport
      iwlwifi: pcie: prefer to load the firmware in one shot
      iwlwifi: enable shadow registers for 7000
      iwlwifi: mvm: add a missing define in firmware API
      iwlwifi: constify the source buffer of iwl_trans_write_mem
      iwlwifi: mvm: use proper scan type for P2P
      iwlwifi: take valid ant for HT caps from TLV
      iwlwifi: mvm: fix the LUT for BT Coex
      iwlwifi: mvm: limit the length of the AMPDU when BT is running
      iwlwifi: mvm: don't start BA agreement when BT is active
      iwlwifi: mvm: don't enable MIMO when BT is active
      iwlwifi: mvm: reorder Rx handler for performance purposes
      iwlwifi: mvm: correctly configure MCAST in AP mode
      iwlwifi: mvm: fix MCAST in AP mode

Eran Harary (3):
      iwlwifi: support loading NVM data from file
      iwlwifi: fix initialisation while RF-kill is asserted
      iwlwifi: don't return -ERFKILL if SEND_IF_RFKILL is set

Eytan Lifshitz (2):
      iwlwifi: mvm: add thermal throttling and CT kill
      iwlwifi: mvm: don't request SMPS on non-STA iface

Felix Fietkau (6):
      cfg80211: add support for per-chain signal strength reporting
      mac80211: add support for per-chain signal strength reporting
      cfg80211: support an active monitor interface flag
      mac80211: support active monitor interfaces
      ath9k_hw: fix PA predistortion miscalibration
      ath9k: advertise support for active monitor interfaces

Gabor Juhos (7):
      rt2x00: rt2x00dev: use rt2x00dev->tx->limit
      rt2x00: rt61pci: use rt2x00dev->tx->limit
      rt2x00: rt2800pci: use rt2x00dev->tx->limit
      rt2x00: rt2800usb: use rt2x00dev->rx->limit
      rt2x00: rt2800lib: use rt2x00dev->bcn->winfo_size
      rt2x00: rt2x00dev: defer operational mode detection
      rt2x00: rt2x00queue: initialize data_queue fields earlier

Hila Gonen (2):
      iwlwifi: mvm: Add beacon filtering support
      iwlwifi: mvm: Add support for connection monitor offload

Ilan Peer (4):
      iwlwifi: mvm: Loosen the channel context/phy context coupling
      iwlwifi: mvm: Change PHY context handling
      iwlwifi: mvm: Allow P2P Device to use an existing PHY context
      iwlwifi: mvm: Fix quota command settings

Jakub Kicinski (1):
      rt2x00pci: Use PCI MSIs whenever possible

Javier Cardona (2):
      ath9k_htc: Add support for mesh interfaces
      ath9k_htc: Claim support for mgmt frame protection

Joe Perches (1):
      cw1200: hwio: Remove an unnecessary goto

Johannes Berg (41):
      iwlwifi: mvm: don't assume data section is at 0x800000
      iwlwifi: pcie: dump stack on NIC error in sync commands
      iwlwifi: nvm: honour VHT enable flag
      iwlwifi: mvm: optionally store D3 SRAM after resume
      iwlwifi: mvm: sanity check context in iwl_mvm_phy_ctxt_unref()
      mac80211: fix HT beacon-based channel switch handling
      wireless: move crypto constants to ieee80211.h
      mac80211: write memcpy differently for smatch
      cfg80211: use C99 initialisers to simplify code a bit
      iwlwifi: mvm: fix NVM parsing error path
      iwlwifi: reverse DATA/INST section order
      iwlwifi: nvm: don't print NVM section reads by default
      iwlwifi: mvm: don't store section offset/length in debugfs
      iwlwifi: mvm: adjust firmware D3 configuration API
      iwlwifi: mvm: remove P2P_DEVICE support
      mac80211_hwsim: remove P2P_DEVICE support
      mac80211: assign AP_VLAN hw queues correctly
      mac80211: close AP_VLAN interfaces before unregistering all
      Merge remote-tracking branch 'mac80211/master' into mac80211-next
      cfg80211: move cfg80211_get_dev_from_ifindex under wext
      cfg80211: use atomic_t for wiphy counter
      cfg80211: vastly simplify locking
      cfg80211/mac80211: use cfg80211 wdev mutex in mac80211
      cfg80211: simplify and correct P2P-Device scan check
      regulatory: use RCU in regulatory_hint_11d()
      regulatory: remove reg_mutex
      cfg80211: remove some locked wrappers from mlme API
      cfg80211: remove some locked wrappers from sme API
      iwlwifi: move D3_CFG_COMPLETE handling into DVM
      iwlwifi: dvm: rename iwl_lib_ops to iwl_dvm_cfg
      iwlwifi: move some configuration parameters into DVM
      iwlwifi: dvm: constify configuration structs
      Merge remote-tracking branch 'iwlwifi-fixes/master' into HEAD
      cfg80211: make WoWLAN configuration available to drivers
      cfg80211: remove cleanup_work kernel-doc
      mac80211: always send multicast on CAB queue
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: mvm: implement D3 testing
      Revert "iwlwifi: mvm: remove P2P_DEVICE support"
      Revert "mac80211_hwsim: remove P2P_DEVICE support"
      mac80211: fix sdata locking around __ieee80211_request_smps

John Greene (1):
      brcmsmac: Reduce log spam in heavy tx, make err print in debug

John W. Linville (5):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      cfg80211: Allow TDLS peer AID to be configured for VHT

Libo Chen (1):
      drivers/net/wireless/brcm80211/brcmfmac: add missing platform_driver =
owner

Marcel Holtmann (1):
      nl80211: Add generic netlink module alias for cfg80211/nl80211

Nishant Sarmukadam (1):
      mwl8k: Fix the firmware hang issue for 8764

Oleksij Rempel (3):
      mac80211: add STBC flag for radiotap
      ath9k: remove useless flag conversation.
      ath9k: check for Rx-STBC flag and pass it to ieee80211

Oren Givon (1):
      iwlwifi: add new 7260 and 3160 series device IDs

Rafa=C5=82 Mi=C5=82ecki (3):
      bcma: don't hardcode SPROM length
      bcma: prepare for supporting more SPROM sizes
      bcma: support SPROM rev 10

Robert P. J. Day (1):
      wireless: fix kerneldoc content in *80211.h files.

Sachin Kamat (2):
      net: wireless: p54spi: Use module_spi_driver macro
      net: wireless: p54spi: Fix commenting style

Solomon Peachy (12):
      cw1200: add driver for the ST-E CW1100 & CW1200 WLAN chipsets
      cw1200: Fix compile with CONFIG_PM=3Dn
      cw1200: Rename 'sbus' to 'hwbus'
      cw1200: move platform_data header to correct location.
      cw1200: Reference correct 'powerup' GPIO signal.
      cw1200: Replace use of 'struct resource' with 'int' for GPIO fields.
      cw1200: Rework SDIO platform support to prevent build problems.
      cw1200: rename the cw1200 platform definition header
      cw1200: Sanity-check arguments in copy_from_user()
      cw1200: Remove "ITP" debug subsystem.
      cw1200: Eliminate the ETF debug/engineering code.
      cw1200: Fix an assorted pile of checkpatch warnings.

Stanislaw Gruszka (32):
      rt2800: make rt2800_init_bbp return void
      rt2800: prepare for rt2800_init_bbp spit
      rt2800: add rt2800_init_bbp_305x_soc subroutine
      rt2800: move 3352 bbp specific code
      rt2800: move rt2800_bbp4_mac_if_ctrl to proper subroutines
      rt2800: initialize BBP_R31 on proper subroutines
      rt2800: initialize BBP_R47 on 3352 subroutine
      rt2800: initialize BBP_R65 & BBP_R66 on all subroutines (except 5592)
      rt2800: initialize BBP_R68 on proper subroutines
      rt2800: initialize BBP_R69 - BBP_R77 on proper subroutines
      rt2800: initialize BBP_R70 on all subroutines (except 5592)
      rt2800: initialize BBP_R74 - BBP_R80 on all subroutines (except 5592)
      rt2800: initialize BBP_R82 on all subroutines (except 5592)
      rt2800: initialize BBP_R83 on all subroutines (except 5592)
      rt2800: initialize BBP_R84 on all subroutines (except 5592)
      rt2800: initialize BBP_R86 on all subroutines (except 5592)
      rt2800: initialize BBP_R88 on proper subroutines
      rt2800: initialize BBP_R91 on all subroutines (except 5592)
      rt2800: initialize BBP_R92 on all subroutines (except 5592)
      rt2800: move initialization of BBP_95 & BBP_98 to 53xx subroutine
      rt2800: initialize BBP_R103 on all subroutines (except 5592)
      rt2800: initialize BBP_R104 on proper subroutines
      rt2800: initialize BBP_R105 on all subroutines (except 5592)
      rt2800: initialize BBP_R106 on all subroutines (except 5592)
      rt2800: initialize BBP_R120 on 3352 subroutine
      rt2800: initialize BBP_R128 on proper subroutines
      rt2800: initialize BBP_R134 & BBP_R135 on 53xx subroutine
      rt2800: initialize BBP_R104 on 3352 subroutine
      rt2800: initialize BBP_R108 on proper subroutines
      rt2800: move 3352 specific bbp initialization
      rt2800: move 3290 specific bbp initialization
      rt2800: move 53xx specific bbp initialization

Sujith Manoharan (10):
      ath9k: Remove MAC_DEBUG
      ath9k: Use bitops for scan flag
      ath9k: Do not use local_bh_disable in ampdu_action
      ath9k: Return early for invalid rates
      ath9k: Enable WoW only for AR9462
      ath9k: Remove unused structure ath_dbg_bb_mac_samp
      ath9k: Simplify ANI initialization
      ath9k: Set ofdmWeakSigDetect directly
      ath9k: Print ANI statistics in debugfs
      ath9k: Do not maintain ANI state per-channel

Thomas Pedersen (1):
      ath9k: use ap style beaconing for mesh

Vladimir Kondratiev (10):
      cfg80211: add 60GHz regulatory class
      wil6210: 'length' in Tx/Rx descriptors is little endian
      wil6210: Sanity check for reported DMA length
      wil6210: debug dump packet content right after DMA
      wil6210: trace support
      wil6210: use NAPI
      wil6210: fix remaining use of non-cached copy of tx/rx descriptors
      wil6210: do not stop Tx queue on packet drop
      wil6210: channel off by 1
      wil6210: Don't use wdev->sme_state

Wei Yongjun (5):
      wil6210: use kfree_skb() instead of kfree()
      cw1200: remove duplicated include from wsm.c
      cw1200: convert to use simple_open()
      cw1200: use module_spi_driver to simplify the code
      cw1200: remove unused including <linux/version.h>

Yijing Wang (1):
      net, ipw2x00: remove redundant D0 power state set

Yogesh Ashok Powar (1):
      mwifiex: add support for Marvell SD8897 chipset

Yunlian Jiang (1):
      rtlwifi: initialize local array and set value.

 Documentation/DocBook/80211.tmpl                   |    2 -
 MAINTAINERS                                        |    5 +
 drivers/bcma/sprom.c                               |   71 +-
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    2 +
 drivers/net/wireless/ath/ath9k/Kconfig             |    8 -
 drivers/net/wireless/ath/ath9k/ani.c               |   57 +-
 drivers/net/wireless/ath/ath9k/ani.h               |   12 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    4 -
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |   14 -
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   19 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    8 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  418 +---
 drivers/net/wireless/ath/ath9k/debug.h             |   59 -
 drivers/net/wireless/ath/ath9k/htc.h               |    7 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |    5 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   35 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   17 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   13 +-
 drivers/net/wireless/ath/ath9k/init.c              |   19 +-
 drivers/net/wireless/ath/ath9k/link.c              |    9 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   16 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    4 +-
 drivers/net/wireless/ath/ath9k/main.c              |   47 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    9 +-
 drivers/net/wireless/ath/ath9k/wow.c               |  168 +-
 drivers/net/wireless/ath/wil6210/Kconfig           |   12 +
 drivers/net/wireless/ath/wil6210/Makefile          |   21 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    4 +
 drivers/net/wireless/ath/wil6210/debug.c           |   69 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |    8 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   29 +-
 drivers/net/wireless/ath/wil6210/main.c            |   24 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   54 +
 drivers/net/wireless/ath/wil6210/trace.c           |   20 +
 drivers/net/wireless/ath/wil6210/trace.h           |  235 ++
 drivers/net/wireless/ath/wil6210/txrx.c            |  175 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |   32 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   27 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   13 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    3 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    2 +-
 drivers/net/wireless/cw1200/Kconfig                |   30 +
 drivers/net/wireless/cw1200/Makefile               |   21 +
 drivers/net/wireless/cw1200/bh.c                   |  619 +++++
 drivers/net/wireless/cw1200/bh.h                   |   28 +
 drivers/net/wireless/cw1200/cw1200.h               |  323 +++
 drivers/net/wireless/cw1200/cw1200_sdio.c          |  425 ++++
 drivers/net/wireless/cw1200/cw1200_spi.c           |  463 ++++
 drivers/net/wireless/cw1200/debug.c                |  428 ++++
 drivers/net/wireless/cw1200/debug.h                |   93 +
 drivers/net/wireless/cw1200/fwio.c                 |  520 +++++
 drivers/net/wireless/cw1200/fwio.h                 |   39 +
 drivers/net/wireless/cw1200/hwbus.h                |   33 +
 drivers/net/wireless/cw1200/hwio.c                 |  310 +++
 drivers/net/wireless/cw1200/hwio.h                 |  246 ++
 drivers/net/wireless/cw1200/main.c                 |  600 +++++
 drivers/net/wireless/cw1200/pm.c                   |  367 +++
 drivers/net/wireless/cw1200/pm.h                   |   43 +
 drivers/net/wireless/cw1200/queue.c                |  583 +++++
 drivers/net/wireless/cw1200/queue.h                |  116 +
 drivers/net/wireless/cw1200/scan.c                 |  461 ++++
 drivers/net/wireless/cw1200/scan.h                 |   56 +
 drivers/net/wireless/cw1200/sta.c                  | 2404 ++++++++++++++++=
++++
 drivers/net/wireless/cw1200/sta.h                  |  123 +
 drivers/net/wireless/cw1200/txrx.c                 | 1474 ++++++++++++
 drivers/net/wireless/cw1200/txrx.h                 |  106 +
 drivers/net/wireless/cw1200/wsm.c                  | 1823 +++++++++++++++
 drivers/net/wireless/cw1200/wsm.h                  | 1873 +++++++++++++++
 drivers/net/wireless/ipw2x00/ipw2100.c             |    2 -
 drivers/net/wireless/iwlegacy/commands.h           |    8 -
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   21 +-
 drivers/net/wireless/iwlwifi/dvm/calib.c           |    8 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |   12 -
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   57 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |  107 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   20 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   18 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   45 +-
 drivers/net/wireless/iwlwifi/dvm/power.c           |    6 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |    8 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |   12 +-
 drivers/net/wireless/iwlwifi/dvm/tt.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   12 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |   10 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    3 -
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   39 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    4 -
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   32 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   53 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   49 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   19 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    3 +
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |   15 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    3 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    7 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   20 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   12 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   21 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    2 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |    8 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  176 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  428 +++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |    8 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   93 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    1 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  233 ++
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   37 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   36 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  262 ++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  200 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  212 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   37 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |   76 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |  196 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   25 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  141 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   17 +
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   22 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    6 -
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   13 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    6 +
 drivers/net/wireless/iwlwifi/mvm/tt.c              |  512 +++++
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   41 +
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   50 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   51 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   17 +-
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   77 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    1 +
 drivers/net/wireless/mwifiex/fw.h                  |   17 +
 drivers/net/wireless/mwifiex/init.c                |   53 +-
 drivers/net/wireless/mwifiex/join.c                |    5 +-
 drivers/net/wireless/mwifiex/main.c                |   14 +
 drivers/net/wireless/mwifiex/main.h                |    5 +-
 drivers/net/wireless/mwifiex/scan.c                |   23 +-
 drivers/net/wireless/mwifiex/sdio.c                |  463 ++--
 drivers/net/wireless/mwifiex/sdio.h                |  340 ++-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   62 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   17 +
 drivers/net/wireless/mwifiex/uap_cmd.c             |   21 +
 drivers/net/wireless/mwifiex/uap_event.c           |   25 +-
 drivers/net/wireless/mwl8k.c                       |   11 +-
 drivers/net/wireless/p54/p54spi.c                  |   37 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  782 ++++---
 drivers/net/wireless/rt2x00/rt2800pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   36 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    9 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   44 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
 include/linux/ieee80211.h                          |    9 +
 include/linux/platform_data/net-cw1200.h           |   81 +
 include/linux/ssb/ssb_regs.h                       |    1 +
 include/net/cfg80211.h                             |   89 +-
 include/net/ieee80211_radiotap.h                   |    7 +
 include/net/mac80211.h                             |   14 +-
 include/uapi/linux/nl80211.h                       |   24 +
 net/mac80211/aes_ccm.c                             |    6 +-
 net/mac80211/cfg.c                                 |   33 +-
 net/mac80211/debugfs_netdev.c                      |   15 +-
 net/mac80211/driver-ops.h                          |    3 +-
 net/mac80211/ht.c                                  |    4 +-
 net/mac80211/ibss.c                                |   49 +-
 net/mac80211/ieee80211_i.h                         |   28 +-
 net/mac80211/iface.c                               |   29 +-
 net/mac80211/key.c                                 |   24 +-
 net/mac80211/key.h                                 |   15 +-
 net/mac80211/main.c                                |    4 +-
 net/mac80211/mesh.c                                |   38 +-
 net/mac80211/mesh_plink.c                          |    7 +-
 net/mac80211/mlme.c                                |  345 +--
 net/mac80211/rx.c                                  |   30 +-
 net/mac80211/sta_info.c                            |    2 +
 net/mac80211/sta_info.h                            |    5 +
 net/mac80211/tx.c                                  |    5 +-
 net/mac80211/util.c                                |   36 +-
 net/mac80211/wep.c                                 |   48 +-
 net/mac80211/wpa.c                                 |   68 +-
 net/wireless/core.c                                |  224 +-
 net/wireless/core.h                                |   93 +-
 net/wireless/debugfs.c                             |    4 +-
 net/wireless/ibss.c                                |   10 +-
 net/wireless/mesh.c                                |    3 +-
 net/wireless/mlme.c                                |  216 +-
 net/wireless/nl80211.c                             |  350 ++-
 net/wireless/reg.c                                 |  136 +-
 net/wireless/scan.c                                |   47 +-
 net/wireless/sme.c                                 |  107 +-
 net/wireless/sysfs.c                               |    8 +-
 net/wireless/trace.h                               |    4 +-
 net/wireless/util.c                                |   39 +-
 net/wireless/wext-compat.c                         |   22 +-
 net/wireless/wext-sme.c                            |   41 +-
 206 files changed, 19923 insertions(+), 3391 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/debug.c
 create mode 100644 drivers/net/wireless/ath/wil6210/trace.c
 create mode 100644 drivers/net/wireless/ath/wil6210/trace.h
 create mode 100644 drivers/net/wireless/cw1200/Kconfig
 create mode 100644 drivers/net/wireless/cw1200/Makefile
 create mode 100644 drivers/net/wireless/cw1200/bh.c
 create mode 100644 drivers/net/wireless/cw1200/bh.h
 create mode 100644 drivers/net/wireless/cw1200/cw1200.h
 create mode 100644 drivers/net/wireless/cw1200/cw1200_sdio.c
 create mode 100644 drivers/net/wireless/cw1200/cw1200_spi.c
 create mode 100644 drivers/net/wireless/cw1200/debug.c
 create mode 100644 drivers/net/wireless/cw1200/debug.h
 create mode 100644 drivers/net/wireless/cw1200/fwio.c
 create mode 100644 drivers/net/wireless/cw1200/fwio.h
 create mode 100644 drivers/net/wireless/cw1200/hwbus.h
 create mode 100644 drivers/net/wireless/cw1200/hwio.c
 create mode 100644 drivers/net/wireless/cw1200/hwio.h
 create mode 100644 drivers/net/wireless/cw1200/main.c
 create mode 100644 drivers/net/wireless/cw1200/pm.c
 create mode 100644 drivers/net/wireless/cw1200/pm.h
 create mode 100644 drivers/net/wireless/cw1200/queue.c
 create mode 100644 drivers/net/wireless/cw1200/queue.h
 create mode 100644 drivers/net/wireless/cw1200/scan.c
 create mode 100644 drivers/net/wireless/cw1200/scan.h
 create mode 100644 drivers/net/wireless/cw1200/sta.c
 create mode 100644 drivers/net/wireless/cw1200/sta.h
 create mode 100644 drivers/net/wireless/cw1200/txrx.c
 create mode 100644 drivers/net/wireless/cw1200/txrx.h
 create mode 100644 drivers/net/wireless/cw1200/wsm.c
 create mode 100644 drivers/net/wireless/cw1200/wsm.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/tt.c
 create mode 100644 include/linux/platform_data/net-cw1200.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRt3UKAAoJEJctW/TcYTgGkz4QAJqzZNVb3HBoW0sGwJwavI04
j5CbtbB5GYV/JjXhxQYIupvF+ORt3xcJmScTiyLHaxACmN203gy8KCIX5vyysFLJ
Fau5zmRNYks7zpM62dbNfwcURMm9s5TF7tLVFIeq6+NN1J6xQX/I8IN7YWRRiRbE
2ttjqs4RMBB4/imEW6JWj3kjSIOlcQw15kTFecKK999pavU+roSTQABsPaAYTJcM
iYNM0Td5S0aqFqWFR8wbWzA/LxgO7mnLt2FOpWBPKORRpFm06cSKzKaHuXH7bdEB
zWbn+ayTCfk1n/cxUegg6I3E3m9VGqvdpo4talC6KQZkUgEZcUGn8hCJdpuZPsQl
EWdUJHw+ZaZHnjBC2EgwB55M+M3ZWVV5Cit4IP/x9g9HZhjJay6vQHZGOTJ7sKFW
uM9L+godsgCEakNvkzn066Y4gS57zdDviAbhVmRsgbIA1eNQisYZBNILN75dFCR1
zuSPeL7XyRRH9Rfr4ATls3fxf55fhyv38RlUYHayvr8+Yk/g8yfgJrLThYy5ChiZ
eGLYFO6DGxeU3FRSRkXfiDZNR8+s94MsiOWNZ0ioJ6pcSre2tgu8AZqZ/9iP1RzF
yrl4TS8H2VOWRad0GCf+ZyJX03SIWi2OxOP/qayFGopJDTy95eW6DpvKfRN23BXy
x6qQxF3kYwm5NgSklAk9
=yGS4
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--
