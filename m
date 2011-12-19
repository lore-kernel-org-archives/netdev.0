From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-12-19
Date: Mon, 19 Dec 2011 14:11:11 -0500
Message-ID: <20111219191110.GB31462@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another (and probably still not the last) big pull request
with updates intended for 3.3.  There is the usual high activity
in the iwlwifi and ath9k camps.  Johannes favors us with some
mac80211 refactoring.  Rafa=C5=82 gives us some more b43 N-phy updates.
Samuel gives us another batch of NFC goodness.  The Broadcom folks
give us another big batch of updates to their drivers.  The wl12xx
guys make a good showing.  And as usual, there are a variety of other
contributions as well.

Please let me know if there are problems!

John

---

The following changes since commit d1d182e00d72300e05b18e28372fab003d8d=
4a58:

  wimax/i2400m: remove an unused variable (2011-12-16 15:57:03 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.=
git for-davem

Amitkumar Karwar (3):
      mwifiex: failure case handling for PCIe events
      mwifiex: do not advertise custom regulatory domain capability
      mwifiex: remove cfg_workqueue

Arend van Spriel (33):
      bcma: add set/mask macros for 16-bit register access
      bcma: use static keyword for inline function declaration in bcma.=
h
      brcm80211: smac: remove unused fields from struct si_pub definiti=
on
      brcm80211: smac: move fields from struct si_pub to struct si_info
      brcm80211: smac: use inline access functions for struct si_pub fi=
elds
      brcm80211: smac: change from pci device driver to bcma device dri=
ver
      brcm80211: smac: change attach interfaces in main.c for bcma supp=
ort
      brcm80211: smac: rename struct si_info field pbus to pcibus
      brcm80211: smac: change ai_attach interface taking a bcma_bus obj=
ect
      brcm80211: smac: remove enumeration rom parsing function
      brcm80211: smac: use bcma core register access functions for 802.=
11 core
      brcm80211: smac: use DMA-API calls for descriptor allocations
      brcm80211: smac: use bcma function for register access in dma.c
      brcm80211: smac: use bcma functions for register access in phy co=
de
      brcm80211: smac: remove SI_FAST() macro usage
      brcm80211: smac: replace ai_corereg() function with ai_cc_reg()
      brcm80211: smac: remove unused functions and/or prototypes
      brcm80211: smac: use bcma core control functions
      brcm80211: smac: use bcma core access functions in nicpci.c
      brcm80211: smac: change ai_findcoreidx() to ai_findcore()
      brcm80211: smac: use bcma core access functions in otp.c
      brcm80211: smac: use bcma core access function in srom.c
      brcm80211: smac: use bcma core access functions in pmu.c
      brcm80211: smac: use bcma core access functions in aiutils.c
      brcm80211: smac: remove register access macro definitions
      brcm80211: smac: remove empty or unused functions from pmu.c
      brcm80211: smac: INTROFF/INTRESTORE macros removed
      brcm80211: smac: remove interrupt disable callback functionality
      brcm80211: smac: remove ai_switch_core() function
      brcm80211: smac: remove mapped core related function from aiutils=
=2Ec
      brcm80211: smac: cleanup si_info structure definition
      brcm80211: smac: cleanup buscore handling in aiutils.c
      brcm80211: smac: register with bcma for specific 802.11 core revi=
sions

Avinash Patil (2):
      mwifiex: proper cleanup when RX multiport aggregation fails
      mwifiex: wakeup and stop multiple tx queues in net_device

Chun-Yeow Yeoh (1):
      ath9k: Support RSN Mesh

Dan Carpenter (3):
      nfc: signedness bug in __nci_request()
      mac80211: unlock on error path in ieee80211_ibss_join()
      brcm80211: smac: precendence bug in wlc_phy_attach()

Dmitry TARNYAGIN (1):
      mac80211: Do not request FIF_BCN_PRBRESP_PROMISC for HW scan.

Don Fry (7):
      iwlwifi: rename iwl-agn-ucode as iwl-ucode
      iwlwifi: replace iwl_priv reference with iwl_trans for ucode.
      iwlwifi: move ucode_type from iwl_priv to iwl_shared
      iwlwifi: move ucode notification from iwl_priv to iwl_shared
      iwlwifi: move eeprom pointer from iwl_priv to iwl_shared
      iwlwifi: move device_pointers from iwl_priv to iwl_shared
      iwlwifi: move calib_results list from iwl_priv to iwl_trans

Eliad Peller (3):
      mac80211: configure BSS_CHANGED_ARP_FILTER on reconfiguration
      mac80211: don't check sdata_running in vif notifier
      wl12xx: use ieee80211_free_txskb()

Emmanuel Grumbach (5):
      iwlwifi: check the HW when a queue is stuck
      iwlwifi: improve the prints in the reclaim path
      iwlwifi: fix endianity issues in debug prints
      iwlwifi: tid_data is taken twice in iwl_trans_pcie_tx_agg_alloc
      iwlwifi: help to debug AGG SM inconsistencies

=46elix Fietkau (7):
      ath9k: make two mci related functions static
      ath9k: change maximum software retransmission handling
      ath9k: reduce the number of unnecessary BAR tx packets
      ath9k: reduce indentation level in a few places
      ath9k: remove bogus sequence number increment
      ath9k: simplify tx locking
      ath9k: avoid retransmitting aggregation frames that a BAR was sen=
t for

=46ranky Lin (4):
      brcm80211: fmac: save bus interface structure in function 2 devic=
e
      brcm80211: fmac: fix firmware shared structures version
      brcm80211: fmac: add bcm4330 support
      brcm80211: fmac: remove drive strength code for unsupported chips

Helmut Schaa (4):
      ieee80211: Introduce ieee80211_is_first_frag
      mac80211: Make use of ieee80211_is_* functions in tx status path
      rt2x00: Make use of ieee80211_free_txskb in tx path
      mac80211: Use appropriate TID for sending BAR, ADDBA and DELBA fr=
ames

Hsu, Kenny (7):
      iwlwifi: add tm commands for indirect register access
      iwlwifi: add tm commands for sram reading by dumpit
      iwlwifi: add generic chunk size of tm dumpit packet
      iwlwifi: add WOWLAN uCode loading support by testmode
      iwlwifi: add uCode version information support by testmode
      iwlwifi: hide kernel option IWLWIFI_DEVICE_SVTOOL
      iwlwifi: add device ID information support by testmode

Johannes Berg (23):
      iwlagn: remove calibration knowledge
      iwlagn: dynamically allocate & reflect calibration data
      iwlagn: allow up to uCode API 6 for 6000 devices
      iwlagn: fix HW crypto for TX-only keys
      iwlagn: remove TX_REPLY_LIMIT debug
      iwlagn: remove HC_DUMP debug
      iwlagn: remove MACDUMP debug
      iwlagn: make debug levels more readable
      iwlagn: fix TID use bug
      iwlagn: use IWL_MAX_TID_COUNT for WoWLAN
      iwlagn: use IWL_MAX_TID_COUNT instead of TID_MAX_LOAD_COUNT
      iwlwifi: tx_sync only on PAN context
      nl80211: accept testmode dump with netdev
      nl80211: add TDLS peer flag to policy
      cfg80211: validate nl80211 station handling better
      mac80211: remove duplicate TDLS peer verification
      mac80211: use station mutex in configuration
      mac80211: refactor station state transitions
      mac80211: count authorized stations per BSS
      mac80211: make address arguments to sta_info_alloc const
      mac80211: delay IBSS station insertion
      mac80211: reduce station management complexity
      mac80211_hwsim: fix wmediumd_pid

John W. Linville (4):
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/=
iwlwifi
      b43: avoid calling bcma_* if CONFIG_B43_BCMA is not set
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into for-davem

Kenny Hsu (1):
      iwlwifi: add range checking in tm sram read command

Larry Finger (1):
      brcmsmac: Replace kmalloc/memset with kzalloc

Luciano Coelho (5):
      wl12xx: don't write out of bounds when hlid > WL12XX_MAX_LINKS
      wl12xx: call extended radio parameters for wl127x AP mode
      wl12xx: remove deprecated packet detection threshold config
      wl12xx: remove unused firmware version macros
      wl12xx: alloc buffer in driver_state_read to prevent compilation =
warning

Luis R. Rodriguez (4):
      ath: add a helper for processing reg data on init
      ath: optimize processing of CTLs for country IEs for world roamin=
g cards
      ath: document ATH_DBG_MCI
      cfg80211: allow following country IE power for custom regdom card=
s

Mohammed Shafi Shajakhan (6):
      ath9k_hw: check for asynchronous interrupts before bailing out
      ath9k_hw: Fix handling of MCI interrupt
      mac80211: remove an unnecessary paraenthesis
      mac80211: Fix power save in change interface
      ath9k: validate for non-zero BSSID
      ath9k_hw: remove ATH9K_HW_CAP_CST

Pontus Fuchs (2):
      wl12xx: Restore testmode ABI
      Set wlvif->ps_compl to NULL in before return

Rafa=C5=82 Mi=C5=82ecki (15):
      ssb: extract FEM info from SPROM
      bcma: extract FEM info from SPROM
      bcma: support for suspend and resume
      b43: N-PHY: random trivial fixes for typos, missing writes
      b43: N-PHY: update some init values
      b43: N-PHY: workaround BCM43224 hw bug in writing table id 9
      b43: N-PHY: add table for antenna software control
      b43: N-PHY: determine various PHY params
      b43: N-PHY: finish 2.4GHz 0x2056 radio setup
      b43: N-PHY: implement spurious tone avoidance
      bcma: extract revision and TX power IDs from SPROM
      b43: N-PHY: fix 32-bit reads of tables
      b43: N-PHY: workaround broken auto-increment on BCM43224
      b43: N-PHY: update TX power fix
      b43: N-PHY: check for bustype before touching BCMA CC PLLs

Rajkumar Manoharan (4):
      ath9k: fix max phy rate at rate control init
      ath9k: Reconfigure tx power on regulatory update
      cfg80211: notify core hints that helps to restore regd settings
      cfg80211: Restore orig channel values upon disconnect

Samuel Ortiz (8):
      NFC: Add function name to the NFC pr_fmt() routine
      NFC: Add tx skb allocation routine
      NFC: Do not take the genl mutex from the netlink release notifier
      NFC: Atomic socket allocation
      NFC: Add a DEP link control netlink command
      NFC: Set and get DEP general bytes
      NFC: DEP link hook implementation for pn533
      NFC: Initial LLCP support

Simon Wunderlich (1):
      mac80211: free skb on error path of ieee80211_ibss_join()

Stanislaw Gruszka (2):
      rtlwifi: use work for lps
      rtlwifi: merge ips,lps spinlocks into one mutex

Vasanthakumar Thiagarajan (1):
      cfg80211: Fix race in bss timeout

Wey-Yi Guy (17):
      iwlwifi: remove redundancy
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into wireless-next
      iwlwifi: show command string for REPLY_D3_CONFIG
      iwlwifi: show the configuration option
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into wireless-next
      iwlwifi: do not re-configure HT40 after associated
      iwlwifi: declare static for iwl_sram_cleanup function
      iwlwifi: Rename file name from iwl-sv-open.c to iwl-testmode.c
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into wireless-next
      iwlwifi: Display more uCode debug info
      iwlwifi: minor cleanup
      iwlwifi: remove reference to legacy devices
      iwlwifi: rename CONFIG_IWLWIFI_DEVICE_SVTOOL to CONFIG_IWLWIFI_DE=
VICE_TESTMODE
      iwlwifi: P2P is not enabled by default
      iwlwifi: set TX_CMD_FLG_STA_RATE_MSK for BAR frame
      iwlwifi: do not set the sequence control bit is not needed
      iwlwifi: allow to switch to HT40 if not associated

Yogesh Ashok Powar (2):
      mac80211: Purge A-MPDU TX queues before station destructions
      mwifiex: avoid double list_del in command cancel path

Zefir Kurtisi (3):
      ath: add a debug level for DFS
      ath9k_hw: add DFS testing check
      ath9k: add DFS radar pulse processing

 drivers/bcma/bcma_private.h                        |    3 +
 drivers/bcma/host_pci.c                            |   37 +
 drivers/bcma/main.c                                |   16 +
 drivers/bcma/sprom.c                               |   61 +
 drivers/net/wireless/ath/ath.h                     |    6 +
 drivers/net/wireless/ath/ath9k/Kconfig             |   22 +
 drivers/net/wireless/ath/ath9k/Makefile            |    2 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   59 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    9 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    5 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/dfs.c               |  215 ++++
 drivers/net/wireless/ath/ath9k/dfs.h               |   43 +
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |   81 ++
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |   57 +
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    9 +
 drivers/net/wireless/ath/ath9k/hw.c                |   33 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   30 +-
 drivers/net/wireless/ath/ath9k/init.c              |   17 +-
 drivers/net/wireless/ath/ath9k/main.c              |    5 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    8 +-
 drivers/net/wireless/ath/ath9k/mci.h               |    4 -
 drivers/net/wireless/ath/ath9k/rc.c                |    4 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c              |  236 ++--
 drivers/net/wireless/ath/regd.c                    |   77 ++-
 drivers/net/wireless/b43/phy_n.c                   |  312 +++++-
 drivers/net/wireless/b43/phy_n.h                   |    8 +
 drivers/net/wireless/b43/radio_2056.c              |   25 +-
 drivers/net/wireless/b43/radio_2056.h              |    1 +
 drivers/net/wireless/b43/tables_nphy.c             |   77 ++-
 drivers/net/wireless/b43/tables_nphy.h             |   31 +-
 drivers/net/wireless/brcm80211/Kconfig             |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    3 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   25 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    2 +
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |   74 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    1 +
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  | 1239 ++++--------=
--------
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |  148 +--
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    7 +-
 drivers/net/wireless/brcm80211/brcmsmac/d11.h      |    3 +
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  229 ++--
 drivers/net/wireless/brcm80211/brcmsmac/dma.h      |    9 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  166 +--
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    2 -
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  702 ++++++------
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/nicpci.c   |  241 ++--
 drivers/net/wireless/brcm80211/brcmsmac/nicpci.h   |   11 +-
 drivers/net/wireless/brcm80211/brcmsmac/otp.c      |   76 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |  229 ++--
 .../net/wireless/brcm80211/brcmsmac/phy/phy_hal.h  |    4 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   69 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   84 +-
 drivers/net/wireless/brcm80211/brcmsmac/pmu.c      |  270 ++---
 drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |    5 +-
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/srom.c     |   50 +-
 drivers/net/wireless/brcm80211/brcmsmac/srom.h     |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/types.h    |   54 +-
 .../net/wireless/brcm80211/include/chipcommon.h    |    2 +
 drivers/net/wireless/iwlwifi/Kconfig               |   30 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   18 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    5 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   34 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   84 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   30 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   60 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   26 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |   15 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |   49 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   21 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   18 +
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |   32 +-
 drivers/net/wireless/mac80211_hwsim.c              |   21 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  194 +---
 drivers/net/wireless/mwifiex/cfg80211.h            |    1 -
 drivers/net/wireless/mwifiex/cmdevt.c              |    9 +-
 drivers/net/wireless/mwifiex/init.c                |   40 +
 drivers/net/wireless/mwifiex/main.c                |   13 +-
 drivers/net/wireless/mwifiex/main.h                |   18 +-
 drivers/net/wireless/mwifiex/pcie.c                |   20 +-
 drivers/net/wireless/mwifiex/scan.c                |   13 +-
 drivers/net/wireless/mwifiex/sdio.c                |   22 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   23 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/mwifiex/txrx.c                |    5 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    3 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   26 +-
 drivers/net/wireless/rtlwifi/ps.c                  |   21 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    6 +-
 drivers/net/wireless/wl12xx/acx.c                  |   26 -
 drivers/net/wireless/wl12xx/acx.h                  |    8 -
 drivers/net/wireless/wl12xx/debugfs.c              |   16 +-
 drivers/net/wireless/wl12xx/init.c                 |   47 +-
 drivers/net/wireless/wl12xx/init.h                 |    1 -
 drivers/net/wireless/wl12xx/main.c                 |   19 +-
 drivers/net/wireless/wl12xx/rx.c                   |    8 +-
 drivers/net/wireless/wl12xx/testmode.c             |    1 +
 drivers/net/wireless/wl12xx/tx.c                   |    9 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |    7 -
 drivers/nfc/pn533.c                                |  168 +++-
 drivers/ssb/pci.c                                  |   23 +
 include/linux/bcma/bcma.h                          |   55 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |    1 +
 include/linux/ieee80211.h                          |    9 +
 include/linux/nfc.h                                |   29 +-
 include/linux/nl80211.h                            |    6 +-
 include/linux/ssb/ssb.h                            |    9 +
 include/linux/ssb/ssb_regs.h                       |   17 +
 include/net/cfg80211.h                             |   37 +-
 include/net/nfc/nfc.h                              |   21 +-
 net/mac80211/agg-tx.c                              |    6 +-
 net/mac80211/cfg.c                                 |  102 ++-
 net/mac80211/debugfs_netdev.c                      |    2 +
 net/mac80211/ht.c                                  |    2 +-
 net/mac80211/ibss.c                                |  156 ++-
 net/mac80211/ieee80211_i.h                         |   31 +-
 net/mac80211/iface.c                               |    5 +-
 net/mac80211/main.c                                |   11 +-
 net/mac80211/mesh_plink.c                          |    7 +-
 net/mac80211/mlme.c                                |    9 +-
 net/mac80211/rx.c                                  |    4 +-
 net/mac80211/sta_info.c                            |  356 +++----
 net/mac80211/sta_info.h                            |   39 +-
 net/mac80211/status.c                              |   15 +-
 net/mac80211/tx.c                                  |   32 +-
 net/mac80211/util.c                                |    3 +-
 net/nfc/Kconfig                                    |    1 +
 net/nfc/Makefile                                   |    1 +
 net/nfc/core.c                                     |  143 +++-
 net/nfc/llcp/Kconfig                               |    7 +
 net/nfc/llcp/commands.c                            |  399 +++++++
 net/nfc/llcp/llcp.c                                |  973 ++++++++++++=
+++
 net/nfc/llcp/llcp.h                                |  193 +++
 net/nfc/llcp/sock.c                                |  675 +++++++++++
 net/nfc/nci/core.c                                 |    4 +-
 net/nfc/nci/data.c                                 |    2 +-
 net/nfc/nci/ntf.c                                  |    2 +-
 net/nfc/nci/rsp.c                                  |    2 +-
 net/nfc/netlink.c                                  |  148 +++-
 net/nfc/nfc.h                                      |   63 +
 net/nfc/rawsock.c                                  |   11 +-
 net/wireless/core.h                                |    6 +-
 net/wireless/nl80211.c                             |  250 +++--
 net/wireless/reg.c                                 |   62 +-
 net/wireless/sme.c                                 |   61 +-
 net/wireless/util.c                                |    6 +-
 168 files changed, 6761 insertions(+), 3754 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs.h
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_debug.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dfs_debug.h
 create mode 100644 net/nfc/llcp/Kconfig
 create mode 100644 net/nfc/llcp/commands.c
 create mode 100644 net/nfc/llcp/llcp.c
 create mode 100644 net/nfc/llcp/llcp.h
 create mode 100644 net/nfc/llcp/sock.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
