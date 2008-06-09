From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-06-09
Date: Mon, 9 Jun 2008 17:07:37 -0400
Message-ID: <20080609210737.GA15375@tuxdriver.com>
References: <20080522124017.GA3996@tuxdriver.com> <20080603185301.GA28966@tuxdriver.com> <20080603194927.GA9590@tuxdriver.com> <20080609204241.GA11343@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080609204241.GA11343-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Tons of new stuff intended for 2.6.27.  Please let me know if there are
problems!

Thanks,

John

P.S.  This dropps "ipw2200: queue direct scans" but is otherwise the
same as the pull request from 2008-06-03.

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 5b06c85c3b96fa8db632f1ee94f99a2bd0215f3a:
  Allan Stephens (1):
        tipc: Cosmetic cleanup of topology service code

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git

Atsushi Nemoto (1):
      zd1211rw: Use DMA-aware buffer for usb transfer

Daniel Walker (3):
      ps3: gelic: scan_lock semaphore to mutex
      ps3: gelic: assoc_stat_lock semaphore to mutex
      ps3: gelic: updown_lock semaphore to mutex

David Woodhouse (4):
      libertas: Increase priority of 'unknown command' warnings
      libertas: fix multicast filtering on eth and msh interfaces
      libertas: Add reset_card() callback to hardware driver
      libertas: provide reset_card() callback on OLPC

Emmanuel Grumbach (8):
      iwlwifi: don't switch to SGI if not supported by AP
      iwlwifi: clean up and bug fix for security
      mac80211: sends HT IE to user level through wext
      mac80211: allow disable FAT in specific configurations
      iwlwifi: disable FAT channel when not permitted
      iwlwifi: fix a memory leak in scan
      iwlwifi: remove debugfs entries before cfg80211
      iwlwifi: send calibration results as HUGE commands

Ester Kummer (2):
      iwlwifi: trigger event log from debugfs
      iwlwifi: move iwl_dump_nic_error_log to iwlcore module

Gertjan van Wingerde (2):
      rt2x00: Fix queue related oops in case of deselected mac80211 multi-queue feature.
      rt2x00: Only initialize the minimum needed fields of PCI TX descriptors.

Gregory Greenman (2):
      iwlwifi: get_hw_cmd_size
      iwlwifi: use uCode error and event tables pointer w.r.t loaded image

Guy Cohen (1):
      iwlwifi: fix in-column rate scaling

Harvey Harrison (6):
      mac80211: michael.c use kernel-provided infrastructure
      mac80211: introduce struct michael_mic_ctx and static helpers
      mac80211: add const, remove unused function, make one function static
      mac80211: add a struct to hold tkip context
      mac80211: tkip.c use struct tkip_ctx in phase 1 key mixing
      mac80211: tkip.c use struct tkip_ctx in phase 2 key mixing

Holger Schurig (7):
      libertas: reduce command retry time
      libertas: don't spin_unlock_irq() twice
      libertas: speeds up downloading of CF firmware
      libertas: use lbs_pr_XX instead of printk
      libertas: before sleeping, check for a command result
      libertas: fix compact flash interrupt handling
      libertas: unify various CF-related defines

Ivo van Doorn (9):
      rt2x00: trim skb_frame_desc to 32 bytes
      rt2x00: Fix TX status reporting
      rt2x00: Remove ieee80211_tx_control argument from write_tx_desc()
      rt2x00: Preserve descriptor information after memmove()
      rt2x00: Split rt2x00lib_write_tx_desc()
      rt2x00: Remove redundant flags/dev_flags initializations
      rt2x00: Merge RX and TX entry private data
      rt2x00: Remove extra +
      rt2x00: Release rt2x00 2.1.6

Javier Cardona (4):
      libertas: Extend MESH_CONFIG command to access non-volatile configuration
      libertas: sysfs interface for accessing non-volatile configuration
      libertas: sysfs interface for accessing default mesh channel
      libertas: rate adaptation configuration via iwconfig.

Johannes Berg (14):
      mac80211: fix bugs in queue handling functions
      mac80211: let drivers wake but not start queues
      mac80211: use rate index in TX control
      mac80211: reorder some transmit handlers
      mac80211: move TX info into skb->cb
      mac80211: dont allow fragmentation and requeuing on A-MPDU queues
      mac80211: use multi-queue master netdevice
      mac80211: remove channel use statistics
      b43: enable mesh
      mac80211: clean up skb reallocation code
      ath5k: use IEEE80211_SKB_CB
      b43legacy: fix build errors when DMA or PIO are not selected
      p54: fix skb->cb tx info conversion
      mac80211: fix rate control initialisation

Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org (1):
      b43: Fix typo in firmware file name for 802.11 cores with rev 13

Masakazu Mokuno (6):
      PS3: gelic: Allocate the bounce buffer dynamically
      PS3: gelic: Kill the static bounce buffer
      WEXT: Add support for passing PMK and capability flags to WEXT
      PS3: gelic: Use the new PMK interface in the gelic driver
      PS3: gelic: Deprecate the private ioctls in the gelic driver
      PS3: gelic: Add support for ESSID scan

Michael Buesch (4):
      b43: Add hooks for firmware debugging
      b43: Allow running without PCM firmware
      b43: Add panic reason code that doesn't trigger restart
      b43: Add firmware markers support

Pavel Emelyanov (8):
      mac80211: Brush up error paths in mesh_path_add.
      mac80211: Fix one more call to synchronize_rcu in atomic context.
      mac80211: Prepare mesh_table_grow to failing copy_node callback.
      mac80211: Report allocation failure from mesh_path_node_copy.
      mac80211: Fix sleeping allocation under lock in mesh_path_node_copy.
      mac80211: Do not report false error from mesh_path_add.
      mac80211: Merge error paths in mesh_table_grow().
      mac80211: Consolidate hash kfree-ing in mesh.c.

Pavel Roskin (1):
      mac80211: fix panic when using hardware WEP

Ron Rindjunsky (17):
      iwlwifi: changing irrelevant comment
      iwlwifi: remove iwl4965_nic_start function
      mac80211: separate Tx and Rx MCS when configuring HT
      iwlwifi: filling Tx MCS set
      iwlwifi: rename and move Tx queue activation/deactivation
      iwlwifi: add rx_handlers stub for iwl5000
      iwlwifi: add ucode loaders for iwl5000
      iwlwifi: add ucode init flow handling for iwl5000
      iwlwifi: iwl5000 WiFi/WiMax coexistence
      iwlwifi: add RTC data address for iwl5000
      iwlwifi: increase max payload of iwl_cmd
      iwlwifi: activate status ready timeout only for run time ucode
      iwlwifi: add iwl5000_tx_response structure
      iwlwlifi: impelemnt 5000 tx response path
      iwlwifi: iwl-5000 add rxon_assoc
      iwlwifi: Rx handlers common use for 4965 and 5000
      iwlwifi: move iwl_get_hw_mode to iwl-core.h

Scott Ashcroft (1):
      rndis_wlan: use ARRAY_SIZE instead of sizeof when adding 11g rates

Tomas Winkler (40):
      iwlwifi: rename iwl4965_queue to iwl_queue
      iwlwifi: rename iwl4965_tx_info to iwl_tx_info
      iwlwifi: remove 4965 from iwl4965_tx_queue_update_write_ptr
      iwlwifi: remove 4965 prefix from iwl4965_frame
      iwlwifi: remove 4965 from iwl4965_rate_info
      iwlwifi: move iwl_bcast_addr to iwlcore
      iwlwifi: move more station managment into iwl-sta.c
      iwlwifi: remove 4956 form iwl4965_tx_cmd
      iwlwifi: refactor ieee80211_get_qos_ctrl
      iwlwifi: move TX code into iwl-tx.c
      iwlwifi: remove 4965 remainings in iwl-eeprom.c file
      iwlwifi: add debugfs to disable/enable run time calibration
      iwlwifi: refactor pci prob flow
      mac80211: fix ieee80211_get_buffered_bc
      mac80211: fix deadlock in sta->lock
      iwlwifi: mark 4965 ucode types
      iwlwifi: remove unused variable form __iwl4965_down
      iwlwifi: remove notif_missed_beacons variable
      iwlwifi: clean up alive_start routine
      iwlwifi: remove 4965 from alive_resp structures
      iwlwifi: setup correctly L1 L0S pi link values
      iwlwifi: implement apm reset flow
      iwlwifi: implement apm stop function
      iwlwifi: refactor stop master function
      iwlwifi: move txq_ctx_stop into iwl-tx.c
      iwlwifi: move iwl_rxq_stop into iwl-rx.c
      iwlwifi: add remove station functionality
      iwlwifi: move add sta handler to iwl-sta.c
      iwlwifi: move iwl_rx_missed_beacon_notif to iwl-rx.c
      iwlwifi-5000: implement initial calibration for 5000
      iwlwifi: move tx response common handlers to iwlcore
      iwlwifi: move 4965 tx response into iwl-4965.c
      iwlwifi: move tx reclaim flow into iwl-tx
      iwlwifi: implement txq invalidate byte count table
      iwlwifi: move iwl_sta_modify_enable_tid_tx to iwl-sta.c
      iwlwifi: move aggregation code to iwl-tx.c
      iwlwifi: add frame count limit to link quality command
      iwlwifi: clean iwl4965_mac_config
      mac80211: fix unbalanced locking in ieee80211_get_buffered_bc
      mac80211: removing shadowed sband

Zhu Yi (1):
      iwlwifi: create drivers debugfs dir under wiphy->debugfsdir

 drivers/net/Kconfig                         |   13 +
 drivers/net/ps3_gelic_net.c                 |   10 +-
 drivers/net/ps3_gelic_net.h                 |    2 +-
 drivers/net/ps3_gelic_wireless.c            |  206 ++--
 drivers/net/ps3_gelic_wireless.h            |    7 +-
 drivers/net/wireless/adm8211.c              |   35 +-
 drivers/net/wireless/adm8211.h              |    1 -
 drivers/net/wireless/ath5k/base.c           |   74 +-
 drivers/net/wireless/ath5k/base.h           |    1 -
 drivers/net/wireless/b43/b43.h              |   28 +-
 drivers/net/wireless/b43/dma.c              |   46 +-
 drivers/net/wireless/b43/dma.h              |    3 +-
 drivers/net/wireless/b43/main.c             |  225 +++-
 drivers/net/wireless/b43/pio.c              |   36 +-
 drivers/net/wireless/b43/pio.h              |    8 +-
 drivers/net/wireless/b43/xmit.c             |   65 +-
 drivers/net/wireless/b43/xmit.h             |    4 +-
 drivers/net/wireless/b43legacy/dma.c        |   35 +-
 drivers/net/wireless/b43legacy/dma.h        |    7 +-
 drivers/net/wireless/b43legacy/main.c       |   13 +-
 drivers/net/wireless/b43legacy/pio.c        |   19 +-
 drivers/net/wireless/b43legacy/pio.h        |    7 +-
 drivers/net/wireless/b43legacy/xmit.c       |   47 +-
 drivers/net/wireless/b43legacy/xmit.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |   16 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   25 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    5 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |    7 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |  169 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h  |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     | 1019 ++++++----------
 drivers/net/wireless/iwlwifi/iwl-5000.c     |  897 ++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-calib.c    |   27 +
 drivers/net/wireless/iwlwifi/iwl-calib.h    |    9 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h |  243 ++++-
 drivers/net/wireless/iwlwifi/iwl-core.c     |  327 +++++-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   56 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |   55 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |  152 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   28 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h  |   21 +
 drivers/net/wireless/iwlwifi/iwl-prph.h     |   39 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   48 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |  501 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-sta.h      |    7 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       | 1058 +++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   90 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c | 1670 +++------------------------
 drivers/net/wireless/libertas/Makefile      |    8 +-
 drivers/net/wireless/libertas/assoc.c       |    8 +-
 drivers/net/wireless/libertas/cmd.c         |  174 ++-
 drivers/net/wireless/libertas/cmd.h         |    5 +
 drivers/net/wireless/libertas/cmdresp.c     |   25 +-
 drivers/net/wireless/libertas/decl.h        |    4 +
 drivers/net/wireless/libertas/defs.h        |   14 +-
 drivers/net/wireless/libertas/dev.h         |    8 +-
 drivers/net/wireless/libertas/host.h        |   17 +
 drivers/net/wireless/libertas/hostcmd.h     |    4 +-
 drivers/net/wireless/libertas/if_cs.c       |  227 ++--
 drivers/net/wireless/libertas/if_usb.c      |   22 +
 drivers/net/wireless/libertas/main.c        |  216 +++--
 drivers/net/wireless/libertas/persistcfg.c  |  453 ++++++++
 drivers/net/wireless/libertas/rx.c          |    4 +-
 drivers/net/wireless/libertas/types.h       |   30 +
 drivers/net/wireless/libertas/wext.c        |   32 +-
 drivers/net/wireless/p54/p54common.c        |  106 +-
 drivers/net/wireless/p54/p54common.h        |    1 -
 drivers/net/wireless/p54/p54pci.c           |    2 +-
 drivers/net/wireless/rndis_wlan.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |  132 ++-
 drivers/net/wireless/rt2x00/rt2400pci.h     |    5 +
 drivers/net/wireless/rt2x00/rt2500pci.c     |  120 ++-
 drivers/net/wireless/rt2x00/rt2500pci.h     |    5 +
 drivers/net/wireless/rt2x00/rt2500usb.c     |   85 +-
 drivers/net/wireless/rt2x00/rt2500usb.h     |    5 +
 drivers/net/wireless/rt2x00/rt2x00.h        |   52 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c   |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |  226 +---
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    6 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   76 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c     |  103 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h     |   28 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c   |  167 +++-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |   73 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h     |   11 -
 drivers/net/wireless/rt2x00/rt2x00usb.c     |  228 ++--
 drivers/net/wireless/rt2x00/rt2x00usb.h     |   26 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |  133 ++-
 drivers/net/wireless/rt2x00/rt61pci.h       |    5 +
 drivers/net/wireless/rt2x00/rt73usb.c       |   59 +-
 drivers/net/wireless/rt2x00/rt73usb.h       |    5 +
 drivers/net/wireless/rtl8180_dev.c          |   62 +-
 drivers/net/wireless/rtl8187.h              |    6 -
 drivers/net/wireless/rtl8187_dev.c          |   45 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |  161 +--
 drivers/net/wireless/zd1211rw/zd_mac.h      |   16 -
 drivers/net/wireless/zd1211rw/zd_usb.c      |   29 +-
 include/linux/ieee80211.h                   |   20 +-
 include/linux/wireless.h                    |    2 +
 include/net/mac80211.h                      |  348 +++---
 include/net/wireless.h                      |    6 +
 net/mac80211/Kconfig                        |   14 +-
 net/mac80211/Makefile                       |    2 +-
 net/mac80211/cfg.c                          |    4 +-
 net/mac80211/debugfs_key.c                  |    8 +-
 net/mac80211/debugfs_netdev.c               |    9 -
 net/mac80211/debugfs_sta.c                  |    1 -
 net/mac80211/ieee80211_i.h                  |   78 +-
 net/mac80211/iface.c                        |    2 +-
 net/mac80211/key.h                          |   17 +-
 net/mac80211/main.c                         |  291 +++---
 net/mac80211/mesh.c                         |   38 +-
 net/mac80211/mesh.h                         |    2 +-
 net/mac80211/mesh_pathtbl.c                 |   53 +-
 net/mac80211/michael.c                      |  106 +--
 net/mac80211/michael.h                      |    8 +-
 net/mac80211/mlme.c                         |   88 ++-
 net/mac80211/rate.c                         |   12 +-
 net/mac80211/rate.h                         |   33 +-
 net/mac80211/rc80211_pid.h                  |    4 +-
 net/mac80211/rc80211_pid_algo.c             |   22 +-
 net/mac80211/rc80211_pid_debugfs.c          |    8 +-
 net/mac80211/rx.c                           |   72 +-
 net/mac80211/sta_info.c                     |    8 +-
 net/mac80211/sta_info.h                     |    6 +-
 net/mac80211/tkip.c                         |   86 +-
 net/mac80211/tkip.h                         |    4 -
 net/mac80211/tx.c                           |  841 +++++++-------
 net/mac80211/util.c                         |   59 +-
 net/mac80211/wep.c                          |   19 +-
 net/mac80211/wme.c                          |   28 +-
 net/mac80211/wme.h                          |    2 +-
 net/mac80211/wpa.c                          |  135 +--
 137 files changed, 7615 insertions(+), 5452 deletions(-)
 create mode 100644 drivers/net/wireless/libertas/persistcfg.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-06-09.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
