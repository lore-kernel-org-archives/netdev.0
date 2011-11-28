From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-11-28
Date: Mon, 28 Nov 2011 15:02:22 -0500
Message-ID: <20111128200221.GD2681@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 39338b56382ac640614851a80e0bd71994cc664d

Dave,

Another big pull request -- my apologies!  I have a couple of
sub-maintainers that had let their patch queues back-up a bit too
long...

This pull request contains a lot of refactoring in the iwlegacy and
ath6kl drivers.  mac80211 and rndis_wlan get some love as well.  Beyond
that, there is a handful of small updates and minor fixes to some
drivers and around the wireless stack.

Let me know if there are problems!

John

---

The following changes since commit 8b7ff200010600ef7cd9d002f9f8f97edfc7578e:

  net/irda: convert drivers/net/irda/* to use module_platform_driver() (201=
1-11-27 20:29:11 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Aarthi Thiruvengadam (2):
      ath6kl: add support for WPS
      ath6kl: fix missing copy of action frame contents

Ben Greear (2):
      wireless: Support ht-capabilities over-rides.
      mac80211: Support ht-cap over-rides.

Bing Zhao (1):
      mwifiex: add support for Marvell sd8797 device

Chilam Ng (1):
      ath6kl: make sure WLAN power save is enabled during suspend

Christian Lamparter (2):
      p54: use ieee80211_free_txskb
      carl9170: use ieee80211_free_txskb

Dan Carpenter (2):
      mac80211: use kfree_skb() instead of kfree()
      mac80211: memory leak in mesh_queue_preq()

Emmanuel Grumbach (4):
      iwlwifi: check the HW when a queue is stuck
      iwlwifi: improve the prints in the reclaim path
      iwlwifi: fix endianity issues in debug prints
      iwlwifi: tid_data is taken twice in iwl_trans_pcie_tx_agg_alloc

Felix Fietkau (1):
      mac80211: call ieee80211_recalc_idle() after sending packets

George (1):
      rtlwifi: rtl8192cu: Allow retries for USB I/O

Greg Dietsche (9):
      iwlegacy: change IL_WARN to D_HT in il4965_tx_agg_start
      iwlegacy: change IL_ERR to D_HT in iwl4965_rs_tl_turn_on_agg_for_tid
      iwlegacy: 4965: remove vif null check in request_scan
      iwlegacy: 4965-rs: remove null check on sta in il4965_rs_tx_status
      iwlegacy: 4965-rs: remove unnecessary null check for sta and lq_sta
      iwlegacy: 4965-rs: il4965_rs_alloc_sta: remove lq_sta local var
      iwlegacy: 4965-rs: don't return rate from il4965_rs_update_rate_tbl
      iwlegacy: 4965-rs: cleanup il4965_rs_sta_dbgfs_rate_scale_data_read
      iwlegacy: debugfs_ops should depend on CONFIG_IWLEGACY_DEBUGFS

Helmut Schaa (2):
      mac80211: Check rate->idx before rate->count
      mac80211: Get rid of search loop for rate group index

Ilan Elias (1):
      NFC: Fix indentation in nci.h file

Joe Perches (2):
      brcmsmac: Use current logging styles
      iwl-debug: Shrink object by using dev_err and deduplicating formats

Johannes Berg (12):
      mac80211: remove crypto special case for auth frames
      mac80211: use skb list for fragments
      mac80211: move fragment flag adjustment
      mac80211: make TX LED handling independent of fragmentation
      mac80211: transmit fragment list to drivers
      mac80211: remove unused ASSOC_AP flag
      mac80211: minor cleanup to mesh state locking
      cfg80211: add flags for off-channel capabilities
      nl80211: make get_vlan logic more common
      cfg80211/mac80211: Revert "move information element parsing logic to =
cfg80211"
      cfg80211: work around a sparse issue
      mac80211: fix RCU warnings in mesh

John W. Linville (5):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'for-linville' of git://github.com/sgruszka/iwlegacy
      Merge branch 'master' of git://git.kernel.org/.../torvalds/linux
      rtlwifi: squash warning in _usb_read_sync
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (10):
      ath6kl: Add endpoint_stats debugfs file
      ath6kl: Add debugfs file for target roam table
      ath6kl: Add debugfs files for roaming control
      ath6kl: Add debugfs control for keepalive and disconnection timeout
      ath6kl: Allow CCKM AKM and KRK to be configured
      ath6kl: Fix endpoint_stats debugfs buffer length calculation
      ath6kl: Report unique remain-on-channel cookie values
      ath6kl: Remove unused WMI crypto defines
      ath6kl: Fix key configuration to copy at most seq_len from seq
      ath6kl: Do not hide ath6kl_wmi_addkey_cmd() error values

Jussi Kivilinna (5):
      rndis_wlan: split getting current channel to separate function
      rndis_wlan: pass channel info to cfg80211_roamed()
      rndis_wlan: add missing __packed
      rndis_wlan: add reporting of PMKSA candidate events
      rndis_wlan: remove unused macro

Kalle Valo (47):
      ath6kl: remove unused parameters from struct wmi
      ath6kl: fix struct host_app_area endian handling
      ath6kl: return error block size is not power of 2
      ath6kl: move htc_hif to hif.c
      ath6kl: remove unused values from htc_hif.h
      ath6kl: move remaining content from htc_hif.h to hif.h
      ath6kl: fix null skb dereference in ath6kl_rx()
      ath6kl: fix firmware start address for ar6003 hw2.0
      ath6kl: merge htc debug levels
      ath6kl: cleanup htc debug messages
      ath6kl: don't dump full htc packets
      ath6kl: add debug level for hif
      ath6kl: remove unused A_CACHE_LINE_PAD
      ath6kl: use ath6kl prefix in credit functions
      ath6kl: rename struct htc_endpoint_credit_dist.htc_rsvd to htc_ep
      ath6kl: rename struct htc_credit_state_info to ath6kl_htc_credit_info
      ath6kl: move all credit distribution code to htc.c
      ath6kl: use ath6kl_credit prefix consistently
      ath6kl: remove unused debug levels
      ath6kl: add debug messages for credit handling
      ath6kl: add more boot debug messages
      ath6kl: don't use cfg80211_scan_request after cfg80211_scan_done()
      ath6kl: rename ath6kl_wmi_qos_state_init() to _wmi_reset()
      ath6kl: move power control from sdio to core
      ath6kl: add a fixme to ath6kl_htc_wait_target()
      ath6kl: merge ath6kl_init() to ath6kl_core_init()
      ath6kl: separate hardware boot code from module initialisation code
      ath6kl: remove useless cleanup call from ath6kl_bmi_done()
      ath6kl: add a timeout to ath6kl_hif_intr_bh_handler()
      ath6kl: create ath6kl_htc_reset()
      ath6kl: don't print an error for canceled packets
      ath6kl: change name of sdio driver to ath6kl
      ath6kl: create ath6kl_hif_stop()
      ath6kl: power down hardware when interface is down
      ath6kl: fix WLAN_ENABLE usage in ath6kl_close()
      ath6kl: print firmware crashes always
      ath6kl: print seqno in htc debug logs
      ath6kl: add aborted parameter to ath6kl_cfg80211_scan_complete_event()
      ath6kl: create ath6kl_cfg80211_stop()
      ath6kl: reset CONNECT_PEND and CONNECTED flags in ath6kl_cfg80211_sto=
p()
      ath6kl: implement ath6kl_cfg80211_suspend()
      ath6kl: add state variable depicting hw/fw state
      ath6kl: refactor sdio configuration to a separate function
      ath6kl: cut power during suspend
      ath6kl: don't power down hardware when interface is down
      ath6kl: add suspend_cutpower module parameter
      nl80211: add testmode to the list of supported commands

Kevin Fang (1):
      ath6kl: Add WSC IE on the associate message

Larry Finger (3):
      rtlwifi: rtl8192cu: Change firmware upload to use block writes
      rtlwifi: rtl8192cu: Fix endianian issues
      rtlwifi: Remove redundant code from PCI interrupt

Luis R. Rodriguez (2):
      cfg80211: process regulatory DFS region for countries
      cfg80211: pass DFS region to drivers through reg_notifier()

Michael Buesch (1):
      p54spi: Remove FIXME in op_stop

Patrick Kelle (1):
      minstrel_ht: Remove unused function parameters

Raja Mani (11):
      ath6kl: Add wmi functions to add/delete WOW patterns
      ath6kl: Add wmi functions to configure WOW mode and host sleep mode
      ath6kl: Add WOW suspend/resume implementation
      ath6kl: Include new parameter in suspend path for wowlan
      ath6kl: Add new state for WOW mode
      ath6kl: Move ath6kl_cfg80211_stop() call specific to deep sleep and c=
ut pwr
      ath6kl: Invoke WOW suspend/resume calls during PM operation
      ath6kl: Perform WOW resume in RX path in case of SDIO IRQ wake up
      ath6kl: Remove WARN_ON msg in Suspend path
      ath6kl: Expose ath6kl's WOW capabilities to cfg80211
      ath6kl: Remove few unused WMI stuff

Rajkumar Manoharan (3):
      ath9k: Remove enabling btcoex from stomp type change
      ath9k_hw: Cleanup btcoex wlan weights
      ath9k_hw: set btcoex weights for AR9462

Rick Jones (1):
      wireless: use strlcpy routine in .get_drvinfo

Rishi Panjwani (4):
      ath6kl: Implement support for QOS-enable and QOS-disable from userspa=
ce
      ath6kl: Implement support for background scan control from userspace
      ath6kl: Implement support for listen interval from userspace
      ath6kl: Implement support for power parameter control from userspace

Sam Leffler (1):
      ath6kl: unbreak suspend

Sangwook Lee (1):
      ath6kl: Fix compilation error from of.h

Stanislaw Gruszka (68):
      iwlegacy: remove tracing
      iwlegacy: rename iwl to il
      iwlegacy: rename priv to il
      iwlegacy: rename iwlegacy to il
      iwlegacy: remove DEBUG_IO
      iwlegacy: remove DEBUG_LIMIT
      iwlegacy: rename IL_DEBUG_ to D_
      iwlegacy: remove il argument from IWL_ERR/INFO/WARN/CRIT
      iwlegacy: remove IL_CRIT
      iwlegacy: rename il_{read,write}32 to _il_{rd,wr}
      iwlegacy: mark poll bit as unlocked function
      iwlegacy: mark il_{grab,release}_nic_access as unlocked
      iwlegacy: remove _il_{read,write}_direct32
      iwlegacy: rename i/o direct methods
      iwlegacy: rename il_{read,write}_prph
      iwlegacy: remove not needed parentheses
      iwlegacy: rename remaining IWLs to ILs
      iwlegacy: s/iwl_rx_packet/iwl_rx_pkt/
      iwlegacy: partial rxon context cleanup
      iwlegacy: s/il_rx_mem_buffer/il_rx_buf/
      iwlegacy: s/statistics/stats/
      iwlegacy: s/window/win/
      iwlegacy: s/IL_RATE/RATE/
      iwlegacy: s/INDEX/IDX/
      iwlegacy: s/index/idx/
      iwlegacy: s/TABLE/TBL/
      iwlegacy: remove for_each_context
      iwlegacy: rename base 4965 and 3945 file names
      iwlegacy: merge iwl-4965-led.c into 4965.c
      iwlegacy: merge iwl-3945-led.c into 3945.c
      iwlegacy: merge iwl-4965-eeprom.c into 4965.c
      iwlegacy: merge iwl-4965-ucode.c into 4965.c
      iwlegacy: merge iwl-4965-sta.c into 4965-mac.c
      iwlegacy: merge iwl-4965-{tx,rx}.c into 4965-mac.c
      iwlegacy: merge iwl-4965-lib.c into 4965-mac.c
      iwlegacy: rename iwl-4965-{rs,calib,debugfs}.c to 4965-{rs,calib,debu=
g}.c
      iwlegacy: rename iwl-3945-{rs,debugfs}.c to 3945-{rs,debug}.c
      iwlegacy: add accidentally removed comments
      iwlegacy: move iwl-4965-{,hw,debugfs,calib}.h to 4965.h
      iwlegacy: move iwl-3945-{,hw,fh,debugfs}.h to 3945.h
      iwlegacy: s/STATUS_/S_/
      iwlegacy: s/STATISTICS/STATS/
      iwlegacy: rename REPLY_ to N_ or C_
      iwlegacy: s/rx_handler/handler/
      iwlegacy: s/rx_reply/hdl/
      iwlegacy: rename other handlers
      iwlegacy: rename iwl-core.c to common.c
      iwlegacy: merge common .c files
      iwlegacy: rename module name
      iwlegacy: rename iwl-commands.h to commands.h
      iwlegacy: remove il_ieee80211_get_hw_conf
      iwlegacy: move IL_MASK
      iwlegacy: rename iwl-csr.h to csr.h
      iwlegacy: rename iwl-core.h to common.h
      iwlegacy: merge common header files
      iwlegacy: remove iwl-helpers.h
      iwlegacy: merge iwl-legacy-rs.h into common.h
      iwlegacy: merge iwl-power.h into common.h
      iwlegacy: merge iwl-{eeprom,led}.h into common.h
      iwlegacy: rename iwl-prph.h to prph.h
      iwlegacy: use FH39_ prefix in 3945 code
      iwlegacy: use FH49_ prefix in 4965 code
      iwlegacy: merge iwl-fh.h into 4965.h
      iwlegacy: rename iwl-debug.c to debug.c
      iwlegacy: merge iwl-debug.h into common.h
      iwlegacy: indentions and whitespaces
      iwlegacy: checkpatch.pl fixes
      iwlegacy: remove unused IL_AC_UNSET define

Thomas Meyer (1):
      brcm80211: smac: Use kmemdup rather than duplicating its implementati=
on

Vasanthakumar Thiagarajan (42):
      ath6kl: Enable force foreground scan in connected state
      ath6kl: Fix sparse warning "symbol 'conn' shadows an earlier one"
      ath6kl: Replace spin_lock_irqsave with spin_lock_bh
      ath6kl: Claim sdio function only at appropriate places
      ath6kl: Fix htc_packet leak in ath6kl_htc_rx_process_packets()
      ath6kl: Fix htc_packet leak in ath6kl_htc_rx_fetch()
      ath6kl: Avoid processing failed rx packets
      ath6kl: Minor cleanup in msg_look_ahead parameter in ath6kl_htc_rxmsg=
_pending_handler()
      ath6kl: Pass ath6kl structure to ath6kl_init() instead of net_device
      ath6kl: Keep wiphy reference in ath6kl structure
      ath6kl: Refactor wiphy dev and net dev init functions
      ath6kl: Cleanup fw interface type setting
      ath6kl: Define an initial vif structure and use it
      ath6kl: Define interface specific states
      ath6kl: Move ssid and crypto information to vif structure
      ath6kl: Move nw_type to vif structure
      ath6kl: Move bssid information to vif structure
      ath6kl: Move channel information to vif structure
      ath6kl: Move key information to vif structure
      ath6kl: Move aggregation information to vif structure
      ath6kl: Move disconnect timer to vif structure
      ath6kl: Move scan_req info and sme_state to vif
      ath6kl: Move few more vif specific information to struct ath6kl_vif
      ath6kl: Make net and target stats vif specific
      ath6kl: Maintain firmware interface index in struct ath6kl_vif
      ath6kl: Take vif information from wmi event
      ath6kl: Remove net_device from ath6kl
      ath6kl: Cleanup parameters in ath6kl_init_control_info() and ath6kl_i=
nit_profile_info()
      ath6kl: Refactor ath6kl_destroy()
      ath6kl: Use interface index from wmi data headr
      ath6kl: Store hw mac address in struct ath6kl
      ath6kl: Introduce spinlock to protect vif specific information
      ath6kl: Maintain virtual interface in a list
      ath6kl: Use the other variant of netdev (un)register APIs
      ath6kl: Configure inteface information at init time
      ath6kl: Implement add_virtual_intf() and del_virtual_intf()
      ath6kl: Add a modparam to enable multi normal interface support
      ath6kl: Initialize target wlan values for every vif
      ath6kl: Use appropriate wdev from vif
      ath6kl: Fix lockdep warning
      ath6kl: Fix tx packet drop in AP mode with bridge
      ath6kl: Fix error in writing create_qos debugfs

Wey-Yi Guy (1):
      iwlwifi: remove redundancy

Zefir Kurtisi (1):
      ath9k: trivial: reorder rx_tasklet processing

 drivers/net/wireless/Makefile                      |    2 +-
 drivers/net/wireless/ath/ath6kl/Makefile           |    2 +-
 drivers/net/wireless/ath/ath6kl/bmi.c              |    7 +-
 drivers/net/wireless/ath/ath6kl/bmi.h              |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         | 1428 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |   30 +-
 drivers/net/wireless/ath/ath6kl/common.h           |   16 +-
 drivers/net/wireless/ath/ath6kl/core.h             |  202 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |  849 +++-
 drivers/net/wireless/ath/ath6kl/debug.h            |   34 +-
 drivers/net/wireless/ath/ath6kl/hif-ops.h          |   49 +-
 .../net/wireless/ath/ath6kl/{htc_hif.c =3D> hif.c}   |  150 +-
 drivers/net/wireless/ath/ath6kl/hif.h              |   61 +-
 drivers/net/wireless/ath/ath6kl/htc.c              |  725 ++-
 drivers/net/wireless/ath/ath6kl/htc.h              |   18 +-
 drivers/net/wireless/ath/ath6kl/htc_hif.h          |   92 -
 drivers/net/wireless/ath/ath6kl/init.c             |  676 +-
 drivers/net/wireless/ath/ath6kl/main.c             |  668 +--
 drivers/net/wireless/ath/ath6kl/sdio.c             |  335 +-
 drivers/net/wireless/ath/ath6kl/target.h           |    3 +
 drivers/net/wireless/ath/ath6kl/txrx.c             |  221 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |  688 ++-
 drivers/net/wireless/ath/ath6kl/wmi.h              |  243 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |  107 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |   10 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +
 drivers/net/wireless/ath/ath9k/hw.h                |    5 -
 drivers/net/wireless/ath/ath9k/recv.c              |   10 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   15 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |   14 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  145 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    3 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    7 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    7 +-
 drivers/net/wireless/iwlegacy/3945-debug.c         |  505 ++
 drivers/net/wireless/iwlegacy/3945-mac.c           | 3977 ++++++++++++
 drivers/net/wireless/iwlegacy/3945-rs.c            |  995 +++
 drivers/net/wireless/iwlegacy/3945.c               | 2751 ++++++++
 drivers/net/wireless/iwlegacy/3945.h               |  626 ++
 .../iwlegacy/{iwl-4965-calib.c =3D> 4965-calib.c}    |  613 +-
 drivers/net/wireless/iwlegacy/4965-debug.c         |  746 +++
 drivers/net/wireless/iwlegacy/4965-mac.c           | 6536 ++++++++++++++++=
++++
 drivers/net/wireless/iwlegacy/4965-rs.c            | 2860 +++++++++
 drivers/net/wireless/iwlegacy/4965.c               | 2421 ++++++++
 drivers/net/wireless/iwlegacy/4965.h               | 1309 ++++
 drivers/net/wireless/iwlegacy/Kconfig              |   43 +-
 drivers/net/wireless/iwlegacy/Makefile             |   24 +-
 .../iwlegacy/{iwl-commands.h =3D> commands.h}        | 1134 ++--
 drivers/net/wireless/iwlegacy/common.c             | 5707 +++++++++++++++++
 drivers/net/wireless/iwlegacy/common.h             | 3424 ++++++++++
 drivers/net/wireless/iwlegacy/{iwl-csr.h =3D> csr.h} |   93 +-
 drivers/net/wireless/iwlegacy/debug.c              | 1411 +++++
 drivers/net/wireless/iwlegacy/iwl-3945-debugfs.c   |  523 --
 drivers/net/wireless/iwlegacy/iwl-3945-debugfs.h   |   60 -
 drivers/net/wireless/iwlegacy/iwl-3945-fh.h        |  187 -
 drivers/net/wireless/iwlegacy/iwl-3945-hw.h        |  291 -
 drivers/net/wireless/iwlegacy/iwl-3945-led.c       |   63 -
 drivers/net/wireless/iwlegacy/iwl-3945-led.h       |   32 -
 drivers/net/wireless/iwlegacy/iwl-3945-rs.c        |  996 ---
 drivers/net/wireless/iwlegacy/iwl-3945.c           | 2741 --------
 drivers/net/wireless/iwlegacy/iwl-3945.h           |  308 -
 drivers/net/wireless/iwlegacy/iwl-4965-calib.h     |   75 -
 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.c   |  774 ---
 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.h   |   59 -
 drivers/net/wireless/iwlegacy/iwl-4965-eeprom.c    |  154 -
 drivers/net/wireless/iwlegacy/iwl-4965-hw.h        |  811 ---
 drivers/net/wireless/iwlegacy/iwl-4965-led.c       |   73 -
 drivers/net/wireless/iwlegacy/iwl-4965-led.h       |   33 -
 drivers/net/wireless/iwlegacy/iwl-4965-lib.c       | 1194 ----
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c        | 2871 ---------
 drivers/net/wireless/iwlegacy/iwl-4965-rx.c        |  215 -
 drivers/net/wireless/iwlegacy/iwl-4965-sta.c       |  721 ---
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c        | 1378 -----
 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c     |  166 -
 drivers/net/wireless/iwlegacy/iwl-4965.c           | 2183 -------
 drivers/net/wireless/iwlegacy/iwl-4965.h           |  282 -
 drivers/net/wireless/iwlegacy/iwl-core.c           | 2661 --------
 drivers/net/wireless/iwlegacy/iwl-core.h           |  636 --
 drivers/net/wireless/iwlegacy/iwl-debug.h          |  198 -
 drivers/net/wireless/iwlegacy/iwl-debugfs.c        | 1314 ----
 drivers/net/wireless/iwlegacy/iwl-dev.h            | 1364 ----
 drivers/net/wireless/iwlegacy/iwl-devtrace.c       |   42 -
 drivers/net/wireless/iwlegacy/iwl-devtrace.h       |  210 -
 drivers/net/wireless/iwlegacy/iwl-eeprom.c         |  553 --
 drivers/net/wireless/iwlegacy/iwl-eeprom.h         |  344 -
 drivers/net/wireless/iwlegacy/iwl-fh.h             |  513 --
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |  271 -
 drivers/net/wireless/iwlegacy/iwl-helpers.h        |  196 -
 drivers/net/wireless/iwlegacy/iwl-io.h             |  545 --
 drivers/net/wireless/iwlegacy/iwl-led.c            |  205 -
 drivers/net/wireless/iwlegacy/iwl-led.h            |   56 -
 drivers/net/wireless/iwlegacy/iwl-legacy-rs.h      |  456 --
 drivers/net/wireless/iwlegacy/iwl-power.c          |  165 -
 drivers/net/wireless/iwlegacy/iwl-power.h          |   55 -
 drivers/net/wireless/iwlegacy/iwl-rx.c             |  282 -
 drivers/net/wireless/iwlegacy/iwl-scan.c           |  550 --
 drivers/net/wireless/iwlegacy/iwl-spectrum.h       |    4 +-
 drivers/net/wireless/iwlegacy/iwl-sta.c            |  540 +-
 drivers/net/wireless/iwlegacy/iwl-sta.h            |  148 -
 drivers/net/wireless/iwlegacy/iwl-tx.c             |  659 --
 drivers/net/wireless/iwlegacy/iwl3945-base.c       | 4016 ------------
 drivers/net/wireless/iwlegacy/iwl4965-base.c       | 3281 ----------
 .../net/wireless/iwlegacy/{iwl-prph.h =3D> prph.h}   |  133 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   37 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    5 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |    4 -
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   12 +-
 drivers/net/wireless/libertas/ethtool.c            |    7 +-
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/cfp.c                 |   38 +-
 drivers/net/wireless/mwifiex/fw.h                  |    1 +
 drivers/net/wireless/mwifiex/main.h                |    3 +-
 drivers/net/wireless/mwifiex/sdio.c                |   17 +-
 drivers/net/wireless/mwifiex/sdio.h                |    1 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/p54/p54spi.c                  |    6 +-
 drivers/net/wireless/p54/txrx.c                    |    4 +-
 drivers/net/wireless/prism54/islpci_dev.c          |    4 +-
 drivers/net/wireless/rndis_wlan.c                  |   86 +-
 drivers/net/wireless/rtlwifi/base.c                |    6 +-
 drivers/net/wireless/rtlwifi/base.h                |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    3 -
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   60 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    9 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   57 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    7 +-
 include/linux/nl80211.h                            |   35 +
 include/net/cfg80211.h                             |   94 +-
 include/net/mac80211.h                             |   22 +-
 include/net/nfc/nci.h                              |   84 +-
 include/net/regulatory.h                           |    6 +
 net/mac80211/cfg.c                                 |    2 +-
 net/mac80211/debugfs_sta.c                         |    4 +-
 net/mac80211/driver-ops.h                          |    8 +
 net/mac80211/ht.c                                  |   83 +-
 net/mac80211/ieee80211_i.h                         |   75 +-
 net/mac80211/iface.c                               |    2 +-
 net/mac80211/main.c                                |   20 +-
 net/mac80211/mesh.c                                |    2 +-
 net/mac80211/mesh_hwmp.c                           |    7 +-
 net/mac80211/mesh_pathtbl.c                        |   27 +-
 net/mac80211/mesh_plink.c                          |    3 +-
 net/mac80211/mlme.c                                |   30 +-
 net/mac80211/offchannel.c                          |    4 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   62 +-
 net/mac80211/sta_info.h                            |    2 -
 net/mac80211/tx.c                                  |  222 +-
 net/mac80211/util.c                                |  186 +-
 net/mac80211/wep.c                                 |    5 +-
 net/mac80211/work.c                                |   16 +-
 net/mac80211/wpa.c                                 |   25 +-
 net/wireless/core.h                                |   10 +-
 net/wireless/mlme.c                                |   37 +-
 net/wireless/nl80211.c                             |  133 +-
 net/wireless/reg.c                                 |   39 +
 net/wireless/reg.h                                 |    1 +
 net/wireless/sme.c                                 |    7 +-
 net/wireless/util.c                                |  186 +-
 167 files changed, 40220 insertions(+), 39231 deletions(-)
 rename drivers/net/wireless/ath/ath6kl/{htc_hif.c =3D> hif.c} (80%)
 delete mode 100644 drivers/net/wireless/ath/ath6kl/htc_hif.h
 create mode 100644 drivers/net/wireless/iwlegacy/3945-debug.c
 create mode 100644 drivers/net/wireless/iwlegacy/3945-mac.c
 create mode 100644 drivers/net/wireless/iwlegacy/3945-rs.c
 create mode 100644 drivers/net/wireless/iwlegacy/3945.c
 create mode 100644 drivers/net/wireless/iwlegacy/3945.h
 rename drivers/net/wireless/iwlegacy/{iwl-4965-calib.c =3D> 4965-calib.c} =
(55%)
 create mode 100644 drivers/net/wireless/iwlegacy/4965-debug.c
 create mode 100644 drivers/net/wireless/iwlegacy/4965-mac.c
 create mode 100644 drivers/net/wireless/iwlegacy/4965-rs.c
 create mode 100644 drivers/net/wireless/iwlegacy/4965.c
 create mode 100644 drivers/net/wireless/iwlegacy/4965.h
 rename drivers/net/wireless/iwlegacy/{iwl-commands.h =3D> commands.h} (79%)
 create mode 100644 drivers/net/wireless/iwlegacy/common.c
 create mode 100644 drivers/net/wireless/iwlegacy/common.h
 rename drivers/net/wireless/iwlegacy/{iwl-csr.h =3D> csr.h} (84%)
 create mode 100644 drivers/net/wireless/iwlegacy/debug.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-debugfs.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-debugfs.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-fh.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-hw.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-led.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-led.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945-rs.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-3945.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-calib.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-debugfs.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-eeprom.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-hw.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-led.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-led.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-lib.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-rs.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-rx.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-sta.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-tx.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-4965.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-core.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-core.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-debug.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-debugfs.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-dev.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-devtrace.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-devtrace.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-eeprom.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-eeprom.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-fh.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-hcmd.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-helpers.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-io.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-led.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-led.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-legacy-rs.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-power.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-power.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-rx.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-scan.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-sta.h
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-tx.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl3945-base.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl4965-base.c
 rename drivers/net/wireless/iwlegacy/{iwl-prph.h =3D> prph.h} (83%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO0+jNAAoJEJctW/TcYTgGbV4P/3MsMRqZwnUbZnuvFAnwWS5p
nUFwneogQh2hfuXVnATsSawsbsbBLFxYTZspL4RnLDw4LxwRKEbf6qGgYVbi5f9W
hRd5pb5p+dfjo+vkceER/XkWMWcyLaPCx+OqLCyRpAPdz8t5+99MW568a5g7WLyJ
dsZop1QTxxYuQAJwouigAaFFSCNe8/fTdHw3QNTysvBjBpzJjVvUZXlviOi+iRi3
KK5D2wLwm58Y4t9y9vJgIhv5AhKqJmaJ54T9h04P5hRtrBpfX8QVuOOPxmeA2iIV
5im64RelQtC0CHR2wgfXYGph8AdiqT/k6n/R99VvPSvaiFdE1QQbfx2jRTL9TOg6
MtsjVtPw/PWVJNPW7MZEJmTtzu7A5WamNNcF1XRJoD97SAbKWi5G/jhKziUow04/
KTKvCTnydlhN0VSIXqt9vjFp0pWKmIBbGPjsqup1u0+wTiIlfO1Q8PibH6EgjIY9
VlLyLxAGt3yfJTzLqjLluFZ8eHFaRx2Mu6208Z7X1O7+tXqZY7h8oofnKpBOAsOH
WZuVW/i5SuYrw4A7Be3DgAjGRo8R2/YMBmfbQYcFlHVmfHpNc9ZGSBtFo3QIgGh1
OYBub5eqrVD7LCU5LRLMXXnbbaHr8fPvdccZtclBSlP+sCgER//M0Lx0enS8tO+t
FMdNsvryr5lsqY2E3z4q
=0GH/
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
