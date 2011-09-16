From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2011-09-16
Date: Fri, 16 Sep 2011 14:31:19 -0400
Message-ID: <20110916183118.GB22612@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40975 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab1IPSpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 14:45:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is a batch of updates intended for 3.2.  They have been simmering
for a while, since I merged them just before the big kernel.org
shutdown.  That includes time in wireless-testing and linux-next
(albeit the latter is diminished by the kernel.org outage).  For now,
I am just trying to clear the backlog... :-)

This includes a sizable wl12xx pull and a bunch of iwlagn updates.
There are also a number of ath9k updates, some b43 updates, and a
handful of other bits.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 986eaa904129fc888c6c3882f6405a005511=
0e51:

  Merge branch 'master' of ../netdev-next/ (2011-09-16 02:58:54 -0400)

are available in the git repository at:

  git://git.infradead.org/users/linville/wireless-next.git for-davem

Arik Nemtsov (17):
      wl12xx: Revert "wl12xx: schedule TX packets according to FW occup=
ancy"
      wl12xx: Use a single fw for both STA and AP roles
      wl12xx: use 1 spare block in all cases
      wl12xx: handle dummy packet event also in ap mode
      wl12xx: fix session counter
      wl12xx: use dynamic hlids for AP-mode
      wl12xx: re-enable block ack session support
      wl12xx: AP-mode - set STA HT capabilities when adding a STA
      wl12xx: AP-mode - configure STA HT rates on join
      wl12xx: AP-mode - configure HT rate support to the FW
      wl12xx: track freed packets in FW by AC
      wl12xx: schedule TX packets according to FW packet occupancy
      wl12xx: handle wrap-around overflow in released Tx blocks FW coun=
ter
      wl12xx: enable AP advanced functionality
      wl12xx: set the AP-started flag only after setting keys
      wl12xx: AP-mode - prevent Tx to stale/invalid stations
      wl12xx: fix tx_queue_count spurious increment

Axel Lin (1):
      p54spi: add "spi:" prefix for stlc45xx modalias

Christian Lamparter (1):
      p54: Use do_div for 64-bit division to fix 32-bit kernels

Daniel Halperin (1):
      iwlagn: fix compile warnings when CONFIG_PM_SLEEP is not set

Eliad Peller (23):
      wl12xx: temporarily disable advanced ap functions
      wl12xx: remove rx filtering stuff
      wl12xx: update fw status struct
      wl12xx: update acx commands
      wl12xx: update commands & events
      wl12xx: enable/disable role on interface add/remove
      wl12xx: add device role commands
      wl12xx: update scan cmd api
      wl12xx: update rx/tx
      wl12xx: change max/default template size
      wl12xx: use wl1271_acx_beacon_filter_opt for both sta and ap
      wl12xx: add set_rate_mgmt_params acx
      wl12xx: add system_hlid
      wl12xx: add ROC/CROC commands
      wl12xx: replace dummy_join with ROC/CROC commands
      wl12xx: update BT coex configuration params
      wl12xx: call wl12xx_cmd_set_peer_state() in AP mode
      wl12xx: don't remove key if hlid was already deleted
      wl12xx: add wl12xx_cmd_role_start_ibss()
      wl12xx: support IBSS vif type
      wl12xx: use ap_bcast_hlid for recorded keys
      wl12xx: don't remove key if hlid was already deleted
      wl12xx: don't wait for disconnection event

Emmanuel Grumbach (52):
      iwlagn: use iwl_get_debug_level instead of iwl_debug_level
      iwlagn: introduce iwl-shared.h
      iwlagn: introduce struct iwl-shared - known by all layers
      iwlagn: debug_level moves to struct iwl_shared
      iwlagn: hw_params moves to iwl_shared
      iwlagn: cmd_queue moves to iwl_shared
      iwlagn: workqueue moves to iwl_shared
      iwlagn: priv->status moves to iwl_shared
      iwlagn: priv->lock moves to iwl_shared
      iwlagn: priv->mutex moves to iwl_shared
      iwlagn: modify the debug macro to be usable by all the layers
      iwlagn: add IWL_DEBUG_FW_ERRORS
      iwlagn: priv->sta_lock moves to iwl_shared
      iwlagn: bus layer chooses its transport layer
      iwlagn: add comments to iwl_bus / iwl_trans
      iwlagn: transport handler can register debugfs entries
      iwlagn: iwl_rx_queue moves to the iwl_trans_pcie
      iwlagn: move iwl_suspend / iwl_resume to the transport layer
      iwlagn: move ISR related data to transport layer
      iwlagn: move the NIC error flow to the transport layer
      iwlagn: move isr_statistics to transport layer
      iwlagn: reclaim the packets in transport layer
      iwlagn: move reclaim related functions
      iwlagn: move scd_bc_tbls and scd_base_addr to iwl_trans_pcie
      iwlagn: fix the check of IWLAGN_FIRST_AMPDU_QUEUE
      iwlagn: move all iwl_is_XXX helpers to iwl-shared.h
      iwlagn: move iwl_free_pages to iwl-shared.h
      iwlagn: transport layer should receive iwl_trans
      iwlagn: move hcmd_lock to transport layer
      iwlagn: move dump_csr and dump_fh to transport layer
      iwlagn: remove references to priv from the transport layer
      iwlagn: remove unused parameters from hw_params
      iwlagn: iwl-dev.h doesn't include iwl-fh.h any more
      iwlagn: move Keep Warm to transport layer
      iwlagn: add missing includes
      iwlagn: all function iwl-io.c receive iwl_bus
      iwlagn: iwl-pci doesn't include iwl-dev any more
      iwlagn: iwl_tid_data moves to iwl-shared
      iwlagn: remove dereferences of priv from transport
      iwlagn: stop the device before freeing it
      iwlagn: upper layer stores iwl_rxon_context in skb's CB
      iwlagn: set tx_fifo for ampdu in transport layer
      iwlagn: upper layer uses slabs to allocate tx cmds
      iwlagn: move the mapping ac to queue / fifo to transport
      iwlagn: allocate resources for TX BA session in transport
      iwlagn: move the check_empty logic to the transport layer
      iwlagn: move the disable agg logic to transport layer
      iwlagn: cosmetics in iwl-trans.h
      iwlagn: move wait_for_tx_queue_empty to transport layer
      iwlagn: move check_stuck_queue to transport layer
      iwlagn: move the stop / wake queue logic to transport layer
      iwlagn: move tx queues to transport layer

=46elix Fietkau (6):
      ath9k: fix regression in sending aggregated packets
      ath9k: use u8 for the tx key index
      ath9k: clean up the aggregation tid queue
      ath9k: move the sequence number from ath_frame_info to ath_buf
      ath9k: move seqno allocation in the tx path to ath_tx_setup_buffe=
r
      ath9k: defer ath_tx_setup_buffer setup to the first tx attempt du=
ring aggr

=46lorian Fainelli (1):
      ath9k: add missing AR9340 in ath_mac_bb_names

Gery Kahn (1):
      wl12xx: fixes for hw_pg_ver and chip id reporting

Greg Dietsche (1):
      iwlwifi: iwl-agn-rs.c: remove old comment

Joe Perches (2):
      ath: Make ath_dbg void not int
      ath: Make ath_printk void not int and remove unused struct ath_co=
mmon *

Johannes Berg (1):
      iwlagn: handle GO powersave

John W. Linville (4):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      mac80211: refactor skb copy to failq in mesh_path_move_to_queue
      wl12xx/sdio_test.c: fix build breakage from WL127X_FW_NAME change
      Merge branch 'master' of git://git.infradead.org/users/linville/w=
ireless-next into for-davem

Larry Finger (3):
      b43: Relax requirement for descriptors to be in the DMA zone
      ath9k: Fix a smatch warnings
      b43: Fix swatch warning

Mohammed Shafi Shajakhan (2):
      ath9k: use appropriate debug mask
      ath9k: minor cleanup in ani

Peter Huewe (1):
      net/mac80211/debugfs: Convert to kstrou8_from_user

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: use 8K buffers for 64-bit DMA to workaround hardware bug
      b43: make HT-PHY support experimental

Rajkumar Manoharan (3):
      ath9k_hw: Set default slottime as 9us
      ath9k: Fix eifs/usec timeout for AR9287 v1.3+
      ath9k: Add debugfs support for mac/baseband samples

Shahar Levi (1):
      wl12xx: Add support to RX packets payload alignment

Stanislaw Gruszka (1):
      cfg80211: document wiphy->registered

Wey-Yi Guy (7):
      iwlagn: Rename iwlcore prefix
      iwlagn: remove out-dated comments
      iwlagn: enable 11n aggregation without checking traffic load
      iwlagn: support small form factor SKU of 6205
      iwlagn: more comments for bt channel inhibition
      iwlagn: add comments to module parameters
      iwlagn: adding special "D" SKU for 2000 series

 drivers/net/wireless/ath/ath.h                    |   48 +-
 drivers/net/wireless/ath/ath9k/ani.c              |    2 +-
 drivers/net/wireless/ath/ath9k/ani.h              |    5 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c       |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c       |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h            |    7 +-
 drivers/net/wireless/ath/ath9k/debug.c            |  312 ++++-
 drivers/net/wireless/ath/ath9k/debug.h            |   47 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c     |    1 +
 drivers/net/wireless/ath/ath9k/hw.c               |   13 +-
 drivers/net/wireless/ath/ath9k/hw.h               |    2 +-
 drivers/net/wireless/ath/ath9k/init.c             |    1 +
 drivers/net/wireless/ath/ath9k/mac.h              |    3 +-
 drivers/net/wireless/ath/ath9k/main.c             |    2 +
 drivers/net/wireless/ath/ath9k/recv.c             |   24 +-
 drivers/net/wireless/ath/ath9k/reg.h              |    2 +
 drivers/net/wireless/ath/ath9k/xmit.c             |  234 ++--
 drivers/net/wireless/ath/main.c                   |    8 +-
 drivers/net/wireless/b43/Kconfig                  |    6 +-
 drivers/net/wireless/b43/dma.c                    |   31 +-
 drivers/net/wireless/b43/dma.h                    |    3 +-
 drivers/net/wireless/b43/main.c                   |    5 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c           |   42 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c           |   51 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |   72 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c           |   60 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c      |   43 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h         |   13 -
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c        |  676 +--------
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c         |   93 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c       |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c        |   84 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c         |   68 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c         |  913 ++++++------
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c      |   52 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  938 ++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.h            |   63 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h            |   34 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.c           |  284 ++---
 drivers/net/wireless/iwlwifi/iwl-core.h           |  118 +--
 drivers/net/wireless/iwlwifi/iwl-debug.h          |   40 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |  412 +-----
 drivers/net/wireless/iwlwifi/iwl-dev.h            |  329 +----
 drivers/net/wireless/iwlwifi/iwl-devtrace.h       |    2 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c         |   62 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |    1 -
 drivers/net/wireless/iwlwifi/iwl-fh.h             |   20 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h        |   91 +--
 drivers/net/wireless/iwlwifi/iwl-io.c             |  192 ++--
 drivers/net/wireless/iwlwifi/iwl-io.h             |   61 +-
 drivers/net/wireless/iwlwifi/iwl-led.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c            |   43 +-
 drivers/net/wireless/iwlwifi/iwl-pci.h            |  116 ++
 drivers/net/wireless/iwlwifi/iwl-power.c          |   19 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c             |   42 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c           |   97 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h         |  430 ++++++
 drivers/net/wireless/iwlwifi/iwl-sta.c            |  106 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c        |   21 +-
 drivers/net/wireless/iwlwifi/iwl-trans-int-pcie.h |  314 ++++-
 drivers/net/wireless/iwlwifi/iwl-trans-rx-pcie.c  |  862 +++++++++---
 drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c  |  506 +++++--
 drivers/net/wireless/iwlwifi/iwl-trans.c          | 1615 +++++++++++++=
+++-----
 drivers/net/wireless/iwlwifi/iwl-trans.h          |  216 ++-
 drivers/net/wireless/p54/p54spi.c                 |    2 +-
 drivers/net/wireless/p54/txrx.c                   |   12 +-
 drivers/net/wireless/wl12xx/acx.c                 |  322 ++---
 drivers/net/wireless/wl12xx/acx.h                 |  394 ++----
 drivers/net/wireless/wl12xx/boot.c                |   43 +-
 drivers/net/wireless/wl12xx/boot.h                |    3 +-
 drivers/net/wireless/wl12xx/cmd.c                 |  793 ++++++++---
 drivers/net/wireless/wl12xx/cmd.h                 |  329 +++--
 drivers/net/wireless/wl12xx/conf.h                |  352 ++---
 drivers/net/wireless/wl12xx/debugfs.c             |   17 +-
 drivers/net/wireless/wl12xx/event.c               |    6 +-
 drivers/net/wireless/wl12xx/event.h               |   80 +-
 drivers/net/wireless/wl12xx/init.c                |   91 +-
 drivers/net/wireless/wl12xx/io.h                  |    1 -
 drivers/net/wireless/wl12xx/main.c                |  961 ++++++++-----
 drivers/net/wireless/wl12xx/ps.c                  |    4 +-
 drivers/net/wireless/wl12xx/reg.h                 |   75 -
 drivers/net/wireless/wl12xx/rx.c                  |   60 +-
 drivers/net/wireless/wl12xx/rx.h                  |   18 +-
 drivers/net/wireless/wl12xx/scan.c                |   38 +-
 drivers/net/wireless/wl12xx/scan.h                |   25 +-
 drivers/net/wireless/wl12xx/sdio.c                |    4 +-
 drivers/net/wireless/wl12xx/sdio_test.c           |    2 +-
 drivers/net/wireless/wl12xx/spi.c                 |    4 +-
 drivers/net/wireless/wl12xx/tx.c                  |  136 ++-
 drivers/net/wireless/wl12xx/tx.h                  |   16 +-
 drivers/net/wireless/wl12xx/wl12xx.h              |  153 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h        |   25 -
 include/net/cfg80211.h                            |    1 +
 net/mac80211/debugfs.c                            |   14 +-
 net/mac80211/mesh_pathtbl.c                       |    8 +-
 100 files changed, 7670 insertions(+), 6378 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-pci.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-shared.h

Omnibus patch is available here:

	http://bombadil.infradead.org/~linville/wireless-next-2011-09-16.patch=
=2Egz

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
