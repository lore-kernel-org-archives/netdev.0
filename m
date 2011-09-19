From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-09-19
Date: Mon, 19 Sep 2011 16:48:28 -0400
Message-ID: <20110919204828.GG2608@tuxdriver.com>
References: <20110919203639.GF2608@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110919203639.GF2608-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oops -- fat-fingered the linux-wireless email address...

On Mon, Sep 19, 2011 at 04:36:39PM -0400, John W. Linville wrote:
> David,
>=20
> Here is another big batch of updates intended for 3.2 -- still
> clearing-out the backlog...
>=20
> This round includes lots of updates to ath9k, b43, iwlagn, and rt2x00=
=2E
> Some cleanups go to mac80211, along with a number of mesh-mode fixes
> from Javier.
>=20
> Please let me know if there are problems!
>=20
> Thanks,
>=20
> John
>=20
> ---
>=20
> The following changes since commit 765cf9976e937f1cfe9159bf4534967c8b=
f8eb6d:
>=20
>   tcp: md5: remove one indirection level in tcp_md5sig_pool (2011-09-=
17 01:15:46 -0400)
>=20
> are available in the git repository at:
>   ssh://infradead/~/public_git/wireless-next.git for-davem
>=20
> Andres Salomon (1):
>       libertas: prioritize usb8388_olpc.bin firmware on OLPC machines
>=20
> Arik Nemtsov (3):
>       wl12xx: allow 11a AP-mode for wl127x devices
>       mac80211: add flag to indicate HW only Tx-agg setup support
>       mac80211: add ssid config to bss information in AP-mode
>=20
> Bill Jordan (1):
>       ath9k: ath9k_hw_set_txpowerlimit sets previous txpower
>=20
> Christian Lamparter (1):
>       minstrel_ht: fix Open BA session request floods
>=20
> Dan Carpenter (3):
>       mac80211: handle allocation failures in mesh_pathtbl_init()
>       iwlwifi: fix double assign in iwl_start_tx_ba_trans_ready()
>       iwlwifi: signedness bug in iwl_trans_pcie_tx_agg_alloc()
>=20
> Eliad Peller (5):
>       wl12xx: initialize rate_set on band rates initialization
>       wl12xx: increase psm_entry_retries
>       wl12xx: enter psm only after station role was started
>       nl80211/cfg80211: add WIPHY_FLAG_AP_UAPSD flag
>       nl80211/cfg80211/mac80211: fix wme docs
>=20
> Emmanuel Grumbach (6):
>       iwlagn: merge iwl_pci_down and iwl_pci_remove
>       iwlagn: remove priv dereferences from the transport layer
>       iwlagn: clean up of transport layer
>       iwlagn: move traffic_log back to upper layer
>       iwlagn: iwl-trans.c can't dereference iwl_priv any more
>       iwlagn: fix compilation when debug flags is unset
>=20
> Felix Fietkau (27):
>       ath9k_hw: do not apply the 2.4 ghz ack timeout workaround to ct=
s
>       mac80211: retry sending failed BAR frames later instead of tear=
ing down aggr
>       ath9k_hw: drop an unused column in AR5008-AR9002 initvals
>       ath9k_hw: fix the last register write for ar5416 addac
>       ath9k: fix checks for first subframe delimiter padding
>       mac80211: make ieee80211_send_bar available for drivers
>       ath9k: eliminate common->{rx,tx}_chainmask
>       ath9k: move a few functions around
>       ath9k: always call ath_reset from workqueue context
>       ath9k: merge reset related functions
>       ath9k: implement .get_antenna and .set_antenna
>       ath9k: fix enabling interrupts after a hardware error interrupt
>       ath9k: make beacon timer initialization more reliable
>       ath9k: ensure that rx is not enabled during a reset
>       ath9k: remove ATH_TX_XRETRY and BUF_XRETRY flags
>       ath9k: reduce the number of functions that access the tx descri=
ptor
>       ath9k: move ath_buf_set_rate to remove a forward declaration
>       ath9k: call ath9k_hw_set_desc_link for beacon descriptors
>       ath9k_hw: do not recalculate the descriptor checksum in ar9003_=
hw_fill_txdesc
>       ath9k_hw: add a new API for setting tx descriptors
>       ath9k: use the new API for setting tx descriptors
>       ath9k_hw: remove the old tx descriptor API
>       ath9k: optimize ath9k_ps_restore
>       ath9k: remove a redundant check in ath_tx_form_aggr
>       ath9k: optimize ath_tx_rc_status usage
>       ath9k: do not insert padding into tx buffers on AR9380+
>       mac80211: fix endian issues and comments for BAR failure handli=
ng
>=20
> Guy Eilam (1):
>       wl12xx: use 2 spare TX blocks for GEM cipher
>=20
> Helmut Schaa (12):
>       rt2x00: Minor optimizazion in txdone path
>       rt2x00: Add LED_CFG register description
>       rt2x00: Remove incorrect led blink
>       rt2x00: Update some TX descriptor
>       rt2x00: Avoid unnecessary uncached
>       rt2x00: Move bssidx calculation into its own function
>       rt2x00: Introduce sta_add/remove callbacks
>       rt2x00: Add WCID to crypto struct
>       rt2x00: Add WCID to HT TX descriptor
>       rt2x00: Make use of sta_add/remove callbacks in rt2800
>       rt2x00: Forbid aggregation for STAs not programmed into the hw
>       rt2x00: Use the available helper functions to initialize the WC=
ID table
>=20
> Javier Cardona (12):
>       mac80211: Defer tranmission of mesh path errors
>       mac80211: Fix RCU pointer dereference in mesh_path_discard_fram=
e()
>       mac80211: Remove mesh paths when an interface is removed
>       mac80211: Improve mpath state locking
>       mac80211: Remove redundant mesh path expiration checks
>       mac80211: Don't iterate twice over all mpaths when once in suff=
icient
>       mac80211: Consolidate {mesh,mpp}_path_flush into one function
>       mac80211: Consolidate mesh path duplicated functions
>       mac80211: Stop forwarding mesh traffic when tx queues are full
>       mac80211: Start implementing QoS support for mesh interfaces
>       mac80211: Mesh data frames must have the QoS header
>       mac80211: Mark all mesh stations as QoS capable
>=20
> Joe Perches (3):
>       mac80211: Remove unnecessary OOM logging messages
>       rfkill: Remove unnecessary OOM logging messages
>       wireless: Remove unnecessary OOM logging messages
>=20
> Johannes Berg (2):
>       mac80211: further optimise buffer expiry timer
>       cfg80211: verify format of uAPSD information
>=20
> John W. Linville (2):
>       Merge branch 'for-linville' of git://github.com/lucacoelho/wl12=
xx
>       Merge branch 'master' of ssh://infradead/~/public_git/wireless-=
next into for-davem
>=20
> Kalle Valo (1):
>       MAINTAINERS: update ath6kl
>=20
> Luciano Coelho (4):
>       wl12xx: add support for multiple SSIDs in sched_scan
>       wl12xx: use SCAN_SSID_TYPE_PUBLIC when using the wildcard in sc=
hed_scan
>       nl80211/cfg80211: add match filtering for sched_scan
>       Merge branch 'wl12xx-next' into for-linville
>=20
> Mohammed Shafi Shajakhan (2):
>       ath9k: enable LED pin for AR946/8x chipsets
>       ath9k: Fix PS wrappers and enabling LED
>=20
> Pavel Roskin (1):
>       cfg80211: print bandwidth in chan_reg_rule_print_dbg()
>=20
> Rafa=C5=82 Mi=C5=82ecki (20):
>       b43: LCN-PHY: add R/W ops for PHY and radio
>       b43: LCN-PHY: implement more PHY ops before radio init
>       b43: LCN-PHY: prepare functions for channel switching
>       ssb: use u16 for storing board rev
>       bcma: extract some basic info about board from SPROM
>       b43: LCN-PHY: implement saving and restoring PHY & radio config=
uration
>       b43: LCN-PHY: minor fixes
>       b43: LCN-PHY: put tables functions in correct file
>       b43: LCN-PHY: rewrite 0x7 table at the end of init
>       b43: LCN-PHY: upload additional 0x7 table
>       b43: LCN-PHY: rename functions, get rid of magic names
>       b43: LCN-PHY: add conditions for few operations
>       b43: N-PHY: implement enabling TX power control
>       b43: drop Copyright for not really copyrightable info
>       b43: add my copyrights and myself as the module author
>       b43: LCN-PHY: load TX gain table on init
>       b43: N-PHY: use helper for checking IPA
>       b43: N-PHY: replace some hacks with nice tables ops
>       b43: N-PHY: split workarounds into per-PHY-ver functions
>       b43: N-PHY: implement few random missing ops
>=20
> Rajkumar Manoharan (6):
>       ath9k_hw: Fix rx latency of 11a mode
>       mac80211: stop tx before doing hw config and rate update
>       ath9k: Take the samples in unassociated state
>       ath9k: Move cycle conters under cc_lock
>       ath9k_hw: Fix magnitude/phase average in TxIQ Calibration
>       ath9k_hw: Do full chip reset on 11A channels for AR9003
>=20
> Randy Dunlap (1):
>       wireless: fix kernel-doc warning in net/cfg80211.h
>=20
> Senthil Balasubramanian (4):
>       ath9k_hw: Add initvals and register definitions for AR946/8x ch=
ipsets.
>       ath9k_hw: Split tx/rx gain table initval handling
>       ath9k_hw: Add support for AR946/8x chipsets.
>       ath9k_hw: move register definitions to header files
>=20
> Shahar Levi (1):
>       mac80211: Update device channel in case of HW channel switch su=
pported
>=20
> Sven Neumann (2):
>       cfg80211: hold reg_mutex when updating regulatory
>       cfg80211: reorder code to obsolete forward declaration
>=20
> Thomas Pedersen (1):
>       mac80211: check if mesh frame is in RMC after decrypt
>=20
> Vivek Natarajan (1):
>       cfg80211/nl80211: Indicate roaming feature capability to usersp=
ace.
>=20
> Wey-Yi Guy (4):
>       iwlagn: only perform necessary calibration at init time
>       iwlagn: disply queue read/write pointer when stuck
>       iwlagn: enable 11n support for "_d" sku
>       iwlagn: remove lines from the wrong place
>=20
> Yogesh Ashok Powar (2):
>       mwl8k: Set hardware flag IEEE80211_HW_AP_LINK_PS
>       mwifiex: replace kmalloc & memcpy sequence with kmemdup
>=20
> zero.lin (1):
>       rt2x00: Add new chipset support
>=20
>  MAINTAINERS                                        |   14 +-
>  drivers/bcma/sprom.c                               |    9 +
>  drivers/net/wireless/ath/ath.h                     |    3 -
>  drivers/net/wireless/ath/ath9k/ar5008_initvals.h   |  131 +-
>  drivers/net/wireless/ath/ath9k/ar9001_initvals.h   |  266 +-
>  drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   48 +-
>  drivers/net/wireless/ath/ath9k/ar9002_initvals.h   | 3403 ++++++++++=
----------
>  drivers/net/wireless/ath/ath9k/ar9002_mac.c        |  257 +-
>  drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   17 +-
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  117 +-
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    3 +-
>  drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  581 +++-
>  drivers/net/wireless/ath/ath9k/ar9003_mac.c        |  331 +--
>  drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   15 +-
>  drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   10 +
>  drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  100 +-
>  .../net/wireless/ath/ath9k/ar9480_1p0_initvals.h   | 1833 ++++++++++=
+
>  .../net/wireless/ath/ath9k/ar9480_2p0_initvals.h   | 1928 ++++++++++=
+
>  drivers/net/wireless/ath/ath9k/ath9k.h             |   14 +-
>  drivers/net/wireless/ath/ath9k/beacon.c            |   56 +-
>  drivers/net/wireless/ath/ath9k/debug.c             |   41 +-
>  drivers/net/wireless/ath/ath9k/debug.h             |    6 +-
>  drivers/net/wireless/ath/ath9k/gpio.c              |    2 +
>  drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    7 +-
>  drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    3 +-
>  drivers/net/wireless/ath/ath9k/hw-ops.h            |   58 +-
>  drivers/net/wireless/ath/ath9k/hw.c                |  102 +-
>  drivers/net/wireless/ath/ath9k/hw.h                |   28 +-
>  drivers/net/wireless/ath/ath9k/init.c              |   42 +-
>  drivers/net/wireless/ath/ath9k/mac.c               |   12 -
>  drivers/net/wireless/ath/ath9k/mac.h               |   42 +-
>  drivers/net/wireless/ath/ath9k/main.c              |  535 ++--
>  drivers/net/wireless/ath/ath9k/pci.c               |    5 +-
>  drivers/net/wireless/ath/ath9k/recv.c              |    7 +-
>  drivers/net/wireless/ath/ath9k/reg.h               |   62 +-
>  drivers/net/wireless/ath/ath9k/xmit.c              |  607 ++--
>  drivers/net/wireless/b43/b43.h                     |    2 +
>  drivers/net/wireless/b43/bus.c                     |    2 +
>  drivers/net/wireless/b43/main.c                    |    3 +
>  drivers/net/wireless/b43/phy_ht.c                  |    2 +
>  drivers/net/wireless/b43/phy_lcn.c                 |  288 ++-
>  drivers/net/wireless/b43/phy_n.c                   |  543 ++--
>  drivers/net/wireless/b43/phy_n.h                   |    4 +
>  drivers/net/wireless/b43/radio_2055.c              |    1 +
>  drivers/net/wireless/b43/radio_2056.c              |    2 +
>  drivers/net/wireless/b43/radio_2056.h              |   26 -
>  drivers/net/wireless/b43/radio_2059.c              |    2 +
>  drivers/net/wireless/b43/tables_nphy.c             |    1 +
>  drivers/net/wireless/b43/tables_phy_ht.c           |    2 +
>  drivers/net/wireless/b43/tables_phy_lcn.c          |  255 ++-
>  drivers/net/wireless/b43/tables_phy_lcn.h          |    2 +
>  drivers/net/wireless/iwlwifi/iwl-2000.c            |    1 +
>  drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-tt.h          |    1 -
>  drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |    5 +-
>  drivers/net/wireless/iwlwifi/iwl-agn.c             |   10 +-
>  drivers/net/wireless/iwlwifi/iwl-agn.h             |    2 -
>  drivers/net/wireless/iwlwifi/iwl-commands.h        |    7 +-
>  drivers/net/wireless/iwlwifi/iwl-core.c            |   19 +-
>  drivers/net/wireless/iwlwifi/iwl-core.h            |   22 -
>  drivers/net/wireless/iwlwifi/iwl-csr.h             |   18 +
>  drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   85 +
>  drivers/net/wireless/iwlwifi/iwl-dev.h             |  202 +--
>  drivers/net/wireless/iwlwifi/iwl-helpers.h         |   23 -
>  drivers/net/wireless/iwlwifi/iwl-pci.c             |   18 +-
>  drivers/net/wireless/iwlwifi/iwl-rx.c              |   83 +-
>  drivers/net/wireless/iwlwifi/iwl-shared.h          |   52 +
>  drivers/net/wireless/iwlwifi/iwl-sta.c             |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-sv-open.c         |    1 +
>  drivers/net/wireless/iwlwifi/iwl-trans-int-pcie.h  |  110 +-
>  drivers/net/wireless/iwlwifi/iwl-trans-rx-pcie.c   |   45 +-
>  drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c   |  130 +-
>  drivers/net/wireless/iwlwifi/iwl-trans.c           |  402 +--
>  drivers/net/wireless/iwlwifi/iwl-trans.h           |   66 +-
>  drivers/net/wireless/libertas/if_usb.c             |   21 +
>  drivers/net/wireless/mwifiex/join.c                |    3 +-
>  drivers/net/wireless/mwifiex/scan.c                |    6 +-
>  drivers/net/wireless/mwifiex/sta_ioctl.c           |    9 +-
>  drivers/net/wireless/mwl8k.c                       |    8 +
>  drivers/net/wireless/rt2x00/rt2800.h               |    3 +
>  drivers/net/wireless/rt2x00/rt2800lib.c            |  191 +-
>  drivers/net/wireless/rt2x00/rt2800lib.h            |    5 +-
>  drivers/net/wireless/rt2x00/rt2800pci.c            |   15 +-
>  drivers/net/wireless/rt2x00/rt2800usb.c            |    7 +-
>  drivers/net/wireless/rt2x00/rt2x00.h               |   30 +
>  drivers/net/wireless/rt2x00/rt2x00dev.c            |   21 +
>  drivers/net/wireless/rt2x00/rt2x00mac.c            |   50 +-
>  drivers/net/wireless/rt2x00/rt2x00queue.c          |    7 +-
>  drivers/net/wireless/rt2x00/rt2x00queue.h          |    5 +-
>  drivers/net/wireless/wl12xx/boot.c                 |    4 +-
>  drivers/net/wireless/wl12xx/main.c                 |   50 +-
>  drivers/net/wireless/wl12xx/scan.c                 |   66 +-
>  drivers/net/wireless/wl12xx/tx.c                   |    8 +-
>  drivers/net/wireless/wl12xx/tx.h                   |    1 +
>  drivers/net/wireless/wl12xx/wl12xx.h               |    3 +
>  include/linux/ieee80211.h                          |    2 +
>  include/linux/nl80211.h                            |   57 +-
>  include/linux/ssb/ssb.h                            |    2 +-
>  include/net/cfg80211.h                             |   31 +
>  include/net/mac80211.h                             |   29 +
>  net/mac80211/agg-rx.c                              |   19 +-
>  net/mac80211/agg-tx.c                              |   42 +-
>  net/mac80211/cfg.c                                 |   21 +-
>  net/mac80211/debugfs.c                             |    5 +
>  net/mac80211/debugfs_netdev.c                      |    3 +
>  net/mac80211/ht.c                                  |    6 +-
>  net/mac80211/ieee80211_i.h                         |    3 +-
>  net/mac80211/iface.c                               |    6 +
>  net/mac80211/mesh.c                                |    8 +-
>  net/mac80211/mesh.h                                |    6 +-
>  net/mac80211/mesh_hwmp.c                           |   31 +-
>  net/mac80211/mesh_pathtbl.c                        |  192 +-
>  net/mac80211/mesh_plink.c                          |    2 +-
>  net/mac80211/mlme.c                                |   36 +-
>  net/mac80211/rc80211_minstrel_ht.c                 |    3 +-
>  net/mac80211/rx.c                                  |   35 +-
>  net/mac80211/spectmgmt.c                           |    6 +-
>  net/mac80211/sta_info.c                            |   10 +-
>  net/mac80211/sta_info.h                            |    5 +
>  net/mac80211/status.c                              |   53 +-
>  net/mac80211/tx.c                                  |   26 +-
>  net/mac80211/util.c                                |   13 +-
>  net/mac80211/wme.c                                 |   16 +-
>  net/mac80211/wme.h                                 |    3 +-
>  net/mac80211/work.c                                |    6 +-
>  net/rfkill/rfkill-regulator.c                      |    1 -
>  net/wireless/core.c                                |    2 +-
>  net/wireless/core.h                                |    2 -
>  net/wireless/lib80211_crypt_ccmp.c                 |    2 -
>  net/wireless/lib80211_crypt_tkip.c                 |    4 -
>  net/wireless/lib80211_crypt_wep.c                  |    4 -
>  net/wireless/nl80211.c                             |   73 +-
>  net/wireless/reg.c                                 |   33 +-
>  net/wireless/reg.h                                 |    2 +
>  net/wireless/util.c                                |    5 +-
>  137 files changed, 9864 insertions(+), 4598 deletions(-)
>  create mode 100644 drivers/net/wireless/ath/ath9k/ar9480_1p0_initval=
s.h
>  create mode 100644 drivers/net/wireless/ath/ath9k/ar9480_2p0_initval=
s.h
>=20
> Omnibus patch is available here:
>=20
> 	http://bombadil.infradead.org/~linville/wireless-next-2011-09-19.pat=
ch.gz
>=20
> --=20
> John W. Linville		Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
