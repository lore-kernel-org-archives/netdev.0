From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-05-22
Date: Thu, 22 May 2008 08:40:17 -0400
Message-ID: <20080522124017.GA3996@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another week, another 70+ patches -- actually this pace feels a
bit slow!  This batch includes updates to rt2x00, libertas, iwlwifi,
mac80211, and a smattering of other drivers.

Let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 5b06c85c3b96fa8db632f1ee94f99a2bd0215f3a:
  Allan Stephens (1):
        tipc: Cosmetic cleanup of topology service code

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Atsushi Nemoto (1):
      zd1211rw: Use DMA-aware buffer for usb transfer

David Woodhouse (3):
      libertas: Increase priority of 'unknown command' warnings
      libertas: fix multicast filtering on eth and msh interfaces
      libertas: Add reset_card() callback to hardware driver

Emmanuel Grumbach (2):
      iwlwifi: don't switch to SGI if not supported by AP
      iwlwifi: clean up and bug fix for security

Ester Kummer (1):
      iwlwifi: trigger event log from debugfs

Gertjan van Wingerde (2):
      rt2x00: Fix queue related oops in case of deselected mac80211 multi-queue feature.
      rt2x00: Only initialize the minimum needed fields of PCI TX descriptors.

Gregory Greenman (1):
      iwlwifi: get_hw_cmd_size

Harvey Harrison (6):
      mac80211: michael.c use kernel-provided infrastructure
      mac80211: introduce struct michael_mic_ctx and static helpers
      mac80211: add const, remove unused function, make one function static
      mac80211: add a struct to hold tkip context
      mac80211: tkip.c use struct tkip_ctx in phase 1 key mixing
      mac80211: tkip.c use struct tkip_ctx in phase 2 key mixing

Holger Schurig (1):
      libertas: reduce command retry time

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

Javier Cardona (3):
      libertas: Extend MESH_CONFIG command to access non-volatile configuration
      libertas: sysfs interface for accessing non-volatile configuration
      libertas: sysfs interface for accessing default mesh channel

Johannes Berg (8):
      mac80211: fix bugs in queue handling functions
      mac80211: let drivers wake but not start queues
      mac80211: use rate index in TX control
      mac80211: reorder some transmit handlers
      mac80211: move TX info into skb->cb
      mac80211: dont allow fragmentation and requeuing on A-MPDU queues
      mac80211: use multi-queue master netdevice
      mac80211: remove channel use statistics

Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org (1):
      b43: Fix typo in firmware file name for 802.11 cores with rev 13

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

Ron Rindjunsky (9):
      iwlwifi: changing irrelevant comment
      iwlwifi: remove iwl4965_nic_start function
      mac80211: separate Tx and Rx MCS when configuring HT
      iwlwifi: filling Tx MCS set
      iwlwifi: rename and move Tx queue activation/deactivation
      iwlwifi: add rx_handlers stub for iwl5000
      iwlwifi: add ucode loaders for iwl5000
      iwlwifi: add ucode init flow handling for iwl5000
      iwlwifi: iwl5000 WiFi/WiMax coexistence

Tomas Winkler (13):
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

 drivers/net/wireless/adm8211.c              |   35 +-
 drivers/net/wireless/adm8211.h              |    1 -
 drivers/net/wireless/ath5k/base.c           |   74 +-
 drivers/net/wireless/ath5k/base.h           |    1 -
 drivers/net/wireless/b43/b43.h              |   28 +-
 drivers/net/wireless/b43/dma.c              |   46 +-
 drivers/net/wireless/b43/dma.h              |    3 +-
 drivers/net/wireless/b43/main.c             |  192 ++++-
 drivers/net/wireless/b43/pio.c              |   36 +-
 drivers/net/wireless/b43/pio.h              |    8 +-
 drivers/net/wireless/b43/xmit.c             |   65 +-
 drivers/net/wireless/b43/xmit.h             |    4 +-
 drivers/net/wireless/b43legacy/dma.c        |   35 +-
 drivers/net/wireless/b43legacy/dma.h        |    4 +-
 drivers/net/wireless/b43legacy/main.c       |   13 +-
 drivers/net/wireless/b43legacy/pio.c        |   19 +-
 drivers/net/wireless/b43legacy/pio.h        |    4 +-
 drivers/net/wireless/b43legacy/xmit.c       |   47 +-
 drivers/net/wireless/b43legacy/xmit.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |   16 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   25 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |  123 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h  |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |  304 ++-------
 drivers/net/wireless/iwlwifi/iwl-5000.c     |  316 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-calib.c    |    9 +
 drivers/net/wireless/iwlwifi/iwl-calib.h    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h |   86 +++-
 drivers/net/wireless/iwlwifi/iwl-core.c     |  210 +++++-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   24 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |   52 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |   90 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   23 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h  |   19 +
 drivers/net/wireless/iwlwifi/iwl-prph.h     |   28 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |  294 +++++++-
 drivers/net/wireless/iwlwifi/iwl-sta.h      |    5 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       |  651 ++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   85 +--
 drivers/net/wireless/iwlwifi/iwl4965-base.c | 1067 +++------------------------
 drivers/net/wireless/libertas/Makefile      |    8 +-
 drivers/net/wireless/libertas/assoc.c       |    6 +-
 drivers/net/wireless/libertas/cmd.c         |  105 ++--
 drivers/net/wireless/libertas/cmd.h         |    3 +
 drivers/net/wireless/libertas/cmdresp.c     |    5 +-
 drivers/net/wireless/libertas/decl.h        |    4 +
 drivers/net/wireless/libertas/defs.h        |   14 +-
 drivers/net/wireless/libertas/dev.h         |    3 +
 drivers/net/wireless/libertas/host.h        |   17 +
 drivers/net/wireless/libertas/hostcmd.h     |    2 +-
 drivers/net/wireless/libertas/main.c        |  205 ++++--
 drivers/net/wireless/libertas/persistcfg.c  |  453 ++++++++++++
 drivers/net/wireless/libertas/types.h       |   30 +
 drivers/net/wireless/libertas/wext.c        |    5 +-
 drivers/net/wireless/p54/p54common.c        |   93 +--
 drivers/net/wireless/p54/p54common.h        |    1 -
 drivers/net/wireless/p54/p54pci.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |  132 ++--
 drivers/net/wireless/rt2x00/rt2400pci.h     |    5 +
 drivers/net/wireless/rt2x00/rt2500pci.c     |  120 ++--
 drivers/net/wireless/rt2x00/rt2500pci.h     |    5 +
 drivers/net/wireless/rt2x00/rt2500usb.c     |   85 ++--
 drivers/net/wireless/rt2x00/rt2500usb.h     |    5 +
 drivers/net/wireless/rt2x00/rt2x00.h        |   52 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c   |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |  226 +-----
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    6 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   76 ++-
 drivers/net/wireless/rt2x00/rt2x00pci.c     |  103 +--
 drivers/net/wireless/rt2x00/rt2x00pci.h     |   28 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c   |  167 ++++-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |   73 ++-
 drivers/net/wireless/rt2x00/rt2x00reg.h     |   11 -
 drivers/net/wireless/rt2x00/rt2x00usb.c     |  228 +++---
 drivers/net/wireless/rt2x00/rt2x00usb.h     |   26 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |  133 ++--
 drivers/net/wireless/rt2x00/rt61pci.h       |    5 +
 drivers/net/wireless/rt2x00/rt73usb.c       |   59 +-
 drivers/net/wireless/rt2x00/rt73usb.h       |    5 +
 drivers/net/wireless/rtl8180_dev.c          |   62 +-
 drivers/net/wireless/rtl8187.h              |    6 -
 drivers/net/wireless/rtl8187_dev.c          |   45 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |  161 ++---
 drivers/net/wireless/zd1211rw/zd_mac.h      |   16 -
 drivers/net/wireless/zd1211rw/zd_usb.c      |   29 +-
 include/linux/ieee80211.h                   |   18 +-
 include/net/mac80211.h                      |  348 +++++-----
 net/mac80211/Kconfig                        |   14 +-
 net/mac80211/Makefile                       |    2 +-
 net/mac80211/cfg.c                          |    4 +-
 net/mac80211/debugfs_key.c                  |    8 +-
 net/mac80211/debugfs_netdev.c               |    9 -
 net/mac80211/debugfs_sta.c                  |    1 -
 net/mac80211/ieee80211_i.h                  |   76 +--
 net/mac80211/iface.c                        |    2 +-
 net/mac80211/key.h                          |   17 +-
 net/mac80211/main.c                         |  261 ++++----
 net/mac80211/mesh.c                         |   38 +-
 net/mac80211/mesh.h                         |    2 +-
 net/mac80211/mesh_pathtbl.c                 |   53 +-
 net/mac80211/michael.c                      |  106 +--
 net/mac80211/michael.h                      |    8 +-
 net/mac80211/mlme.c                         |   34 +-
 net/mac80211/rate.c                         |   12 +-
 net/mac80211/rate.h                         |   33 +-
 net/mac80211/rc80211_pid.h                  |    4 +-
 net/mac80211/rc80211_pid_algo.c             |   22 +-
 net/mac80211/rc80211_pid_debugfs.c          |    8 +-
 net/mac80211/rx.c                           |   72 +--
 net/mac80211/sta_info.c                     |    8 +-
 net/mac80211/sta_info.h                     |    6 +-
 net/mac80211/tkip.c                         |   86 +--
 net/mac80211/tkip.h                         |    4 -
 net/mac80211/tx.c                           |  729 +++++++++----------
 net/mac80211/util.c                         |   59 +-
 net/mac80211/wep.c                          |    9 +-
 net/mac80211/wme.c                          |   28 +-
 net/mac80211/wme.h                          |    2 +-
 net/mac80211/wpa.c                          |   81 +--
 122 files changed, 5042 insertions(+), 4024 deletions(-)
 create mode 100644 drivers/net/wireless/libertas/persistcfg.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-05-22.patch.bz2
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
