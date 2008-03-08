From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6.26 2008-03-07
Date: Fri, 7 Mar 2008 20:00:06 -0500
Message-ID: <20080308010006.GA12913@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another week, another 89 patches...  Lots of driver updates, and the
inclusion of 802.11s mesh networking.  There is also some SSB bus
support fo "gigabit ethernet", but it is really just support for an
SSB->PCI bridge (i.e. not a new ethernet driver).

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit f59d43899e279c77924a7ada4bec8c70e5aeca06:
  David S. Miller (1):
        [IPV6]: Fix powerpc allmodconfig build warnings.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Assaf Krauss (1):
      iwlwifi: Moving EEPROM handling in iwlcore module

Bruno Randolf (4):
      ath5k: struct ath5k_desc cleanups
      ath5k: move rx and tx status structures out of hardware descriptor
      ath5k: add notes about rx timestamp
      ath5k: work around wrong beacon rx timestamp in IBSS mode

David Woodhouse (4):
      libertas: convert KEY_MATERIAL to a direct command
      libertas: add LED control TLV to types.h
      libertas: convert 802_11_SCAN to a direct command
      libertas: clean up scan.c, remove zeromac and bcastmac

Emmanuel Grumbach (1):
      iwlwifi: Cancel scanning upon association

Guy Cohen (1):
      iwlwifi: 802.11n spec removes AUTO offset for FAT channel

Johannes Berg (23):
      WEXT: add mesh interface type
      mac80211: add mesh interface type
      mac80211: clean up mesh code
      mac80211: mesh hwmp locking fixes
      mac80211: enable mesh in Kconfig
      mac80211: add missing "break" statement in mesh code
      mac80211: clarify mesh Kconfig
      mac80211: export mesh_plink_broken
      mac80211: clean up mesh RX path a bit more
      mac80211: fix kernel-doc comment for mesh_plink_deactivate
      mac80211: reorder a few fields in sta_info
      mac80211: split ieee80211_txrx_data
      mac80211: RCU-ify STA info structure access
      mac80211: split sta_info_add
      mac80211: clean up sta_info and document locking
      mac80211: remove STA entries when taking down interface
      mac80211: don't clear next_hop in path reclaim
      mac80211: add documentation book
      mac80211: fix sta_info mesh timer bug
      b43: verify sta_notify mac80211 callback
      mac80211: always insert key into list
      mac80211: fix hardware scan completion
      mac80211: don't call conf_tx under RCU lock

John W. Linville (1):
      wireless: correct warnings from using '%llx' for type 'u64'

Luis Carlos Cobo (24):
      wireless: various definitions for mesh networking
      nl80211/cfg80211: support for mesh, sta dumping
      mac80211: mesh function and data structures definitions
      mac80211: support functions for mesh
      mac80211: support for mesh interfaces in mac80211 data path
      mac80211: mesh data structures and first mesh changes
      mac80211: mesh changes to the MLME
      mac80211: mesh peer link implementation
      mac80211: mesh path table implementation
      mac80211: code for on-demand Hybrid Wireless Mesh Protocol
      mac80211: mesh statistics and config through debugfs
      mac80211: mesh path and mesh peer configuration
      mac80211: complete the mesh (interface handling) code
      mac80211: fix mesh endianness sparse warnings and unmark it as broken
      mac80211: fix incorrect parenthesis
      mac80211: move comment to better location
      mac80211: breakdown mesh network attributes in different extra fields for wext
      mac80211: clean up use of endianness conversion functions
      mac80211: delete mesh_path timer on mesh_path removal
      mac80211: always force mesh_path deletions
      mac80211: add PLINK_ prefix and kernel doc to enum plink_state
      mac80211: path IE fields macros, fix alignment problems and clean up
      mac80211: fix mesh_path and sta_info get_by_idx functions
      zd1211rw: support for mesh interface and beaconing

Michael Buesch (5):
      ssb: Add Gigabit Ethernet driver
      b43: Add QOS support
      b43: Rename the DMA ring pointers
      b43: Add TX statistics debugging counters
      b43: Fix failed frames status report typo

Nick Kossifidis (8):
      ath5k: Add RF2413 srev values
      ath5k: Add RF2413 initial settings
      ath5k: Identify RF2413 and deal with PHY_SPENDING
      ath5k: more RF2413 stuff
      ath5k: Remove RF5413 from rf gain optimization functions
      ath5k: Fixes for PCI-E cards
      ath5k: Make some changes to follow register dumps.
      ath5k: Add 2413 to srev_names so that it shows up during module load

Reinette Chatre (1):
      iwlwifi: fix potential lock inversion deadlock

Ron Rindjunsky (4):
      mac80211: adding mac80211_tx_control_flags and HT flags
      iwlwifi: use mac80211_tx_control_flags
      mac80211: document IEEE80211_TXCTL_OFDM_HT
      iwlwifi: grab NIC access when disabling aggregations

Tomas Winkler (12):
      iwlwifi: removing unused priv->config
      iwlwifi: refactor init geos function
      iwlwifi: Fix 52 rate report in rx status
      iwlwifi: extract iwl-csr.h
      iwlwifi: Move HBUS address to iwl-csr.h
      iwlwifi: add struct iwl_cfg
      iwlwifi: Take the fw file name from the iwl_cfg.
      iwlwifi: fix locking unbalance in 4965 rate scale
      iwlwifi: add iwl-core module
      iwlwifi: queue functions cleanup
      iwlwifi: Fix 3945 rate scaling
      iwlwifi: 3945 split tx_complete to command and packet function

 Documentation/DocBook/Makefile                   |    3 +-
 Documentation/DocBook/mac80211.tmpl              |  335 +++++++++
 drivers/net/wireless/ath5k/ath5k.h               |   53 +-
 drivers/net/wireless/ath5k/base.c                |  147 +++--
 drivers/net/wireless/ath5k/debug.c               |   37 +-
 drivers/net/wireless/ath5k/debug.h               |    6 +-
 drivers/net/wireless/ath5k/hw.c                  |  441 +++++++-----
 drivers/net/wireless/ath5k/hw.h                  |  150 +++--
 drivers/net/wireless/ath5k/initvals.c            |  233 ++++++-
 drivers/net/wireless/ath5k/phy.c                 |  174 +++++-
 drivers/net/wireless/ath5k/reg.h                 |    4 +-
 drivers/net/wireless/b43/b43.h                   |   53 ++-
 drivers/net/wireless/b43/dma.c                   |  386 +++++------
 drivers/net/wireless/b43/dma.h                   |   11 +-
 drivers/net/wireless/b43/main.c                  |  196 +++++-
 drivers/net/wireless/b43/main.h                  |    4 +
 drivers/net/wireless/b43/xmit.c                  |   27 -
 drivers/net/wireless/b43/xmit.h                  |   12 -
 drivers/net/wireless/iwlwifi/Kconfig             |    5 +
 drivers/net/wireless/iwlwifi/Makefile            |    3 +
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |   40 +-
 drivers/net/wireless/iwlwifi/iwl-3945-core.h     |   80 ++
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h    |   17 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |  174 -----
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |   76 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |  387 +++++++++--
 drivers/net/wireless/iwlwifi/iwl-3945.h          |   35 +-
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h |   40 +-
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h    |   16 +
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |  175 -----
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |   98 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  352 +++++++--
 drivers/net/wireless/iwlwifi/iwl-4965.h          |   33 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |   47 ++
 drivers/net/wireless/iwlwifi/iwl-core.h          |   84 +++
 drivers/net/wireless/iwlwifi/iwl-csr.h           |  259 +++++++
 drivers/net/wireless/iwlwifi/iwl-eeprom.c        |  205 ++++++
 drivers/net/wireless/iwlwifi/iwl-eeprom.h        |  399 ++++++++++
 drivers/net/wireless/iwlwifi/iwl-helpers.h       |   20 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |  531 +++-----------
 drivers/net/wireless/iwlwifi/iwl4965-base.c      |  351 ++-------
 drivers/net/wireless/libertas/assoc.c            |   12 +-
 drivers/net/wireless/libertas/cmd.c              |  131 ++--
 drivers/net/wireless/libertas/cmd.h              |    2 +
 drivers/net/wireless/libertas/cmdresp.c          |   63 --
 drivers/net/wireless/libertas/hostcmd.h          |   19 +-
 drivers/net/wireless/libertas/scan.c             |  537 ++++++--------
 drivers/net/wireless/libertas/scan.h             |   54 +--
 drivers/net/wireless/libertas/types.h            |   13 +
 drivers/net/wireless/zd1211rw/zd_chip.c          |    1 +
 drivers/net/wireless/zd1211rw/zd_chip.h          |    8 +
 drivers/net/wireless/zd1211rw/zd_mac.c           |   75 ++-
 drivers/net/wireless/zd1211rw/zd_mac.h           |    3 +
 drivers/net/wireless/zd1211rw/zd_usb.c           |   11 +-
 drivers/ssb/Kconfig                              |    9 +
 drivers/ssb/Makefile                             |    1 +
 drivers/ssb/driver_gige.c                        |  294 ++++++++
 drivers/ssb/driver_mipscore.c                    |    1 +
 drivers/ssb/driver_pcicore.c                     |  160 +++--
 drivers/ssb/embedded.c                           |   90 +++
 drivers/ssb/main.c                               |   30 +-
 drivers/ssb/ssb_private.h                        |    2 +
 include/linux/ieee80211.h                        |   35 +
 include/linux/nl80211.h                          |  119 +++-
 include/linux/ssb/ssb.h                          |    7 +
 include/linux/ssb/ssb_driver_gige.h              |  174 +++++
 include/linux/ssb/ssb_driver_pci.h               |   19 +
 include/linux/wireless.h                         |    1 +
 include/net/cfg80211.h                           |  139 +++-
 include/net/mac80211.h                           |  106 ++-
 net/mac80211/Kconfig                             |   16 +
 net/mac80211/Makefile                            |    6 +
 net/mac80211/cfg.c                               |  360 ++++++++--
 net/mac80211/debugfs_netdev.c                    |  197 +++++
 net/mac80211/debugfs_sta.c                       |    6 +-
 net/mac80211/debugfs_sta.h                       |    2 +
 net/mac80211/ieee80211.c                         |  157 +++--
 net/mac80211/ieee80211_i.h                       |  312 +++++++--
 net/mac80211/ieee80211_iface.c                   |   36 +-
 net/mac80211/ieee80211_ioctl.c                   |   61 +-
 net/mac80211/ieee80211_rate.c                    |    8 +-
 net/mac80211/ieee80211_rate.h                    |    1 +
 net/mac80211/ieee80211_sta.c                     |  579 +++++++++++----
 net/mac80211/key.c                               |   18 +-
 net/mac80211/mesh.c                              |  449 +++++++++++
 net/mac80211/mesh.h                              |  290 ++++++++
 net/mac80211/mesh_hwmp.c                         |  857 ++++++++++++++++++++++
 net/mac80211/mesh_pathtbl.c                      |  516 +++++++++++++
 net/mac80211/mesh_plink.c                        |  761 +++++++++++++++++++
 net/mac80211/rc80211_pid_algo.c                  |   36 +-
 net/mac80211/rc80211_simple.c                    |   18 +-
 net/mac80211/rx.c                                |  309 ++++++---
 net/mac80211/sta_info.c                          |  464 ++++++++----
 net/mac80211/sta_info.h                          |  232 +++++--
 net/mac80211/tx.c                                |  432 +++++++-----
 net/mac80211/util.c                              |   28 +-
 net/mac80211/wep.c                               |   24 +-
 net/mac80211/wep.h                               |    4 +-
 net/mac80211/wme.c                               |    8 +-
 net/mac80211/wpa.c                               |   80 +-
 net/mac80211/wpa.h                               |   12 +-
 net/wireless/nl80211.c                           |  438 +++++++++++-
 104 files changed, 10988 insertions(+), 3552 deletions(-)
 create mode 100644 Documentation/DocBook/mac80211.tmpl
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-core.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-core.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-core.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-csr.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom.h
 create mode 100644 drivers/ssb/driver_gige.c
 create mode 100644 include/linux/ssb/ssb_driver_gige.h
 create mode 100644 net/mac80211/mesh.c
 create mode 100644 net/mac80211/mesh.h
 create mode 100644 net/mac80211/mesh_hwmp.c
 create mode 100644 net/mac80211/mesh_pathtbl.c
 create mode 100644 net/mac80211/mesh_plink.c

Omnibus patch available here:

	http://www.kernel.org:/pub/linux/kernel/people/linville/wireless-2.6.25-2008-03-07.patch.gz
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
