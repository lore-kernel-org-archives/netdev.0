From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2011-01-03
Date: Tue, 3 Jan 2012 16:09:13 -0500
Message-ID: <20120103210912.GB24318@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38925 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab2ACVPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 16:15:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 57adc1fcbae2c13104ce291b40f23e40a414fa87

Dave,

I had planned to send a pull request before Christmas, but apparently
I forgot.  So, I reckon this batch of updates got a little extra
testing in linux-next over the past week or so. :-)

This one is kinda big, with pulls from the ath6kl, bluetooth, iwlwifi,
and wl12xx trees.  The brcm80211 team showed a lot of activity,
and both the mwifies and the b43 guys made good showings as well.
A couple of NFC updates and a handful of other bits round things out.

Please let me know if there are problems!

John

---

The following changes since commit faa85aa24286a9e14ae7cc797352350c3ac39986:

  skge: fix warning when CONFIG_PM is defined but not CONFIG_PM_SLEEP (2012=
-01-03 13:53:16 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Aarthi Thiruvengadam (2):
      ath6kl: Fix target minimum length requirement for WMI_SEND_PROBE_RESP=
ONSE_CMDID
      ath6kl: support for P2P mgmt operations on station interface

Alan Cox (1):
      rt2800: Add support for the Fujitsu Stylistic Q550

Amitkumar Karwar (4):
      mwifiex: cleanup work in scan.c
      mwifiex: remove redundant band config code
      mwifiex: use IEEE80211_HT_PARAM_CHA_SEC_* macros
      mwifiex: fix issues in band configuration code

Andrei Emeltchenko (7):
      Bluetooth: Add HCI Read Data Block Size function
      Bluetooth: Simplify num_comp_pkts_evt function
      Bluetooth: Split ctrl init to BREDR and AMP parts
      Bluetooth: Initialize default flow control mode
      Bluetooth: Check for flow control mode
      Bluetooth: Clean up magic pointers
      Bluetooth: Remove magic numbers from le scan cmd

Andres Salomon (1):
      libertas: clean up scan thread handling

Arik Nemtsov (1):
      ath6kl: indicate probe-resp offload support

Bing Zhao (1):
      Bluetooth: btusb: fix bInterval for high/super speed isochronous endp=
oints

Brian Gix (2):
      Bluetooth: Add MITM mechanism to LE-SMP
      Bluetooth: Add SMP to User Passkey and Confirm

Dai Shuibing (3):
      ath6kl: Add support for configuring SMS4 keys
      ath6kl: Allow SMS4 to be configured in AP mode
      ath6kl: Indicate WAPI IE from (Re)Association Request frame

Dan Carpenter (4):
      ath6kl: unlock if ath6kl_cfg80211_connect() fails
      ath6kl: use a larger buffer for debug output
      NFC: double unlock in nfc_llcp_recv_connect()
      NFC: use kfree_skb() for sk_buffs

Don Fry (4):
      iwlwifi: move iwl_cfg from iwl_priv to iwl_shared
      iwlwifi: Add official names for new devices
      iwlwifi: create iwl_mac80211 unregister routine
      iwlwifi: remove most of the iwl_priv references from iwl-ucode.c

Eliad Peller (7):
      wl12xx: implement change_interface
      wl12xx: remove redundant code from wl1271_op_conf_tx
      wl12xx: make WL1271_FLAG_IDLE flag per-vif
      wl12xx: flush packets before stopping dev role
      wl12xx: fix checking of started dev role
      wl12xx: stop device role on remove_interface
      wl12xx: check the actual vif operstate in wl1271_dev_notify

Emmanuel Grumbach (17):
      iwlwifi: fix endianity issue in debug prints
      iwlwifi: don't count the tfds in HW queue any more
      iwlwifi: we can wake SW queues even when draining HW queues
      iwlwifi: don't rely on the wr / rd pointers in DELBA flow
      iwlwifi: tid_data logic move to upper layer - tx AGG stop
      iwlwifi: tid_data logic move to upper layer - tx AGG alloc
      iwlwifi: tid_data logic move to upper layer - tx AGG setup
      iwlwifi: tid_data logic move to upper layer - check_empty
      iwlwifi: tid_data logic move to upper layer - txqid
      iwlwifi: tid_data logic move to upper layer - seq_number
      iwlwifi: transport layer shouldn't access the AGG SM
      iwlwifi: tid_data moves to iwl_priv
      iwlwifi: reset the tid_data when a station is removed
      iwlwifi: add debug in Tx path in AGG flow
      iwlwifi: kill iwl_{start,stop}_tx_ba_trans_ready
      iwlwifi: don't accept Tx packets when draining HW queues
      iwlwifi: add missing documentation for iwl_shared

Eyal Shapira (2):
      wl12xx: fix sched scan of DFS channels
      wl12xx: mark no sched scan only after FW event

Felix Fietkau (2):
      ath9k_hw: make bluetooth coexistence support optional at compile time
      ath9k: fix tx locking issues

Franky Lin (30):
      brcm80211: fmac: unify common layer driver data structure
      brcm80211: fmac: remove oneline proto block functions
      brcm80211: fmac: register a dummy irq handler for SDIO function 2
      brcm80211: fmac: change function add_if parameter
      brcm80211: fmac: change function bus_start parameter
      brcm80211: fmac: change function brcmf_detach parameter
      brcm80211: fmac: change function txflowcontrol parameter
      brcm80211: fmac: change function txcomplete parameter
      brcm80211: fmac: change function brcmf_c_prec_enq parameter
      brcm80211: fmac: change function rx_frame parameter
      brcm80211: fmac: change function proto_hdrpull parameter
      brcm80211: fmac: move sdio used statistics to struct brcmf_sdio
      brcm80211: fmac: move maxctl to struct brcmf_bus
      brcm80211: fmac: move driver up status to struct brcmf_bus
      brcm80211: fmac: remove duplicate statistics from driver data structu=
re
      brcm80211: fmac: move dongle statistics to struct brcmf_bus
      brcm80211: fmac: move packet realloc stats to struct brcmf_bus
      brcm80211: fmac: move tx flow ctrl flag to bus layer
      brcm80211: fmac: stop referencing brcmf_pub in bus layer
      brcm80211: fmac: stop referencing brcmf_sdio in common layer
      brcm80211: fmac: move sdio related macros to sdio_host.h
      brcm80211: fmac: abstract bus_stop interface function pointer
      brcm80211: fmac: move common layer bus interface context to dhd_bus.h
      brcm80211: fmac: abstract bus_init interface function pointer
      brcm80211: fmac: abstract bus_txdata interface function pointer
      brcm80211: fmac: abstract ctrl frames interface function pointers
      brcm80211: fmac: move debug level macros to dhd_dbg.h
      brcm80211: fmac: move idle macros to dhd_sdio.c
      brcm80211: fmac: exclude unnecessary header files
      brcm80211: fmac: add Kconfig option for SDIO bus support

Gustavo F. Padovan (39):
      Bluetooth: remove struct hci_chan_hash
      Bluetooth: remove lock from struct conn_hash
      Bluetooth: Initialize LE connection count
      Bluetooth: Use chan instead of l2cap_pi macro
      Bluetooth: Use list_for_each_entry in hci_conn_hash_flush()
      Bluetooth: make hci_conn_enter_sniff_mode static
      Bluetooth: Replace spin_lock by mutex in hci_dev
      Bluetooth: Use delayed_work for connection timeout
      Bluetooth: Use delayed work for advertisiment cache timeout
      Bluetooth: hci_conn_auto_accept() doesn't need locking
      Bluetooth: Move L2CAP timers to workqueue
      Bluetooth: Don't use spin_lock socket lock anymore
      Bluetooth: Remove sk_backlog usage from L2CAP
      Bluetooth: move hci_task_lock to mutex
      Bluetooth: convert chan_lock to mutex
      Bluetooth: Use RCU to manipulate chan_list
      Bluetooth: convert conn hash to RCU
      Bluetooth: Don't disable tasklets to call hdev->notify()
      Bluetooth: Move command task to workqueue
      Bluetooth: convert tx_task to workqueue
      Bluetooth: convert info timer to delayed_work
      Bluetooth: invert locking order in connect path
      Bluetooth: Change l2cap chan_list to use RCU
      Bluetooth: move power_off to system workqueue
      Bluetooth: Use new alloc_workqueue()
      Bluetooth: Remove work_add and work_del from hci_sysfs
      Bluetooth: Use system workqueue to schedule power_on
      Bluetooth: Add ProFUSION's copyright
      Merge git://git.kernel.org/.../padovan/bluetooth
      Bluetooth: Move l2cap_{set,clear}_timer to l2cap.h
      Bluetooth: convert security timer to delayed_work
      Bluetooth: Rename info_work to info_timer
      Bluetooth: fix bt_accept_dequeue() to work in process context
      Bluetooth: Remove l2cap priority from inside RFCOMM.
      Bluetooth: add debug output to l2cap_ack_timeout()
      Bluetooth: Remove lock from inquiry_cache
      Bluetooth: remove *_bh usage from hci_dev_list and hci_cb_list
      Bluetooth: Don't disable interrupt when locking the queue
      Bluetooth: Fix a compile warning in RFCOMM

Helmut Schaa (1):
      mac80211: Keep skb->piority for relayed frames in AP mode

Hemant Gupta (1):
      Bluetooth: Incorrect address while storing LTK.

Hsu, Kenny (1):
      iwlwifi: add IO function for continuous write of target memory

Jesse Sung (1):
      Bluetooth: Add support for BCM20702A0 [0a5c:21e3]

Joe Perches (1):
      ath: Convert ath_dbg(bar, ATH_DBG_<FOO>, to ath_dbg(bar, FOO

Johan Hedberg (10):
      Bluetooth: Update mgmt_read_info and related mgmt messages
      Bluetooth: Move mgmt_set_fast_connectable to the right location
      Bluetooth: Remove mgmt_set_service_cache
      Bluetooth: Move EIR and CoD update functions to a better position
      Bluetooth: Add timer for automatically disabling the service cache
      Bluetooth: Update ordering and opcodes of mgmt messages
      Bluetooth: Use correct struct for user_confirm_neg_reply
      Bluetooth: Add missing confirm_name field to mgmt_ev_device_found
      Bluetooth: Fix mgmt_(block,unblock)_device opcodes
      Bluetooth: Add missing mgmt_confirm_name command definition

Johannes Berg (6):
      iwlwifi: remove unused AMPDU factor/density configuration
      iwlagn: remove iwlagn_build_addsta_hcmd
      mac80211: handle SMPS action frames
      iwlagn: add IRQ tracing
      iwlagn: finer-grained HT disable
      iwlagn: fix (remove) use of PAGE_SIZE

John W. Linville (7):
      b43: mark some vars __maybe_unused in b43_nphy_pmu_spur_avoid
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/iwlw=
ifi
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-n=
ext
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      ath6kl: Use delayed key configuration for WAPI in AP mode

Kalle Valo (29):
      ath6kl: move bmi calls to hif driver
      ath6kl: change bmi sizes being configurable by HIF
      ath6kl: move diag commands to hif driver
      ath6kl: update ar6004 definitions
      ath6kl: firmware boot fixes for ar6004
      ath6kl: add hif_type
      ath6kl: add USB support
      ath6kl: disable HTC for USB devices
      ath6kl: enable USB support
      ath6kl: remove hw version related parameter defines
      ath6kl: move hw version related to parameters to struct
      ath6kl: add board address to struct ath6kl_hw
      ath6kl: add firmware IE for board data address
      ath6kl: add name field to struct ath6kl_hw
      ath6kl: use hardware version names consistently
      ath6kl: add ar6004 firmwares to sdio module
      ath6kl: add firmware filename info to struct ath6kl_hw
      ath6kl: make maximum number of vifs runtime configurable
      ath6kl: add firmware IE for maximum number of vifs
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: remove unused sc_params from struct ath6kl
      ath6kl: cleanup ath6kl_priv()
      ath6kl: remove a workaround from ath6kl_cfg80211_stop()
      ath6kl: call ath6kl_cfg80211_stop() from ath6kl_close()
      ath6kl: implement ath6kl_cfg80211_stop_all()
      ath6kl: fix value of WOW_FILTER_SSID
      ath6kl: fix reading of FW IE capabilities
      ath6kl: implement scheduled scan
      Merge remote branch 'wireless-next/master' into ath6kl-next

Larry Finger (1):
      rtlwifi: Fix locking problem introduces with commit 6539306b

Luciano Coelho (1):
      wl12xx: add missing copyright notice

Luis R. Rodriguez (4):
      ath6kl: fix ath6kl's set tx power
      ath9k: classify DFS debug header further
      ath9k: fix roadkill due to Joe's patch on ath_dbg() changes
      atheros: force endian checks on atheros wireless drivers

Marcel Holtmann (1):
      Bluetooth: Process recv path in a workqueue instead of a tasklet

Marek Lindner (1):
      mac80211: ibss should not purge clients it is not responsible for

Mat Martineau (1):
      Bluetooth: Incoming ACL packets do not force active mode

Naveen Gangadharan (1):
      ath6kl: AR6004 SDIO support

Nikolay Martynov (1):
      mac80211: split addba retries in time

Paul Stewart (1):
      cfg80211: Return beacon loss count in station

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: N-PHY: reorder functions: put basic ones at beginning
      b43: N-PHY: reorder functions: collect radio ones
      b43: N-PHY: reorder functions: collect samples ones
      b43: N-PHY: reorder functions: collect RSSI selects
      b43: N-PHY: split gain control workarounds
      b43: N-PHY: reorder functions: move RSSI calibration
      b43: N-PHY: reorder functions: move rest of workarounds
      b43: N-PHY: reorder functions: random cleanups

Raja Mani (3):
      ath6kl: Fix cfg80211 warning while starting IBSS mode
      ath6kl: Clear WPS ctrl flag if zero length IE is received from cfg802=
11
      ath6kl: Use mutex to protect dma buffer in sync read write

Ryan Hsu (1):
      ath6kl: Support different uart_tx pin and refclk configuration

Samuel Ortiz (1):
      NFC: Fix LLCP related build failure

Ulisses Furquim (4):
      Bluetooth: Remove global mutex hci_task_lock
      Bluetooth: Always compile SCO and L2CAP in Bluetooth Core
      Bluetooth: Make HCI call directly into SCO and L2CAP event functions
      Bluetooth: Fix deadlocks with sock lock and L2CAP timers locks

Vasanthakumar Thiagarajan (9):
      ath6kl: Fix accessing wrong skb->data in ath6kl_tx_complete()
      ath6kl: Fix packet drop when ath6kl_cookie runs out
      ath6kl: Fix bug in setting default key index for tx in AP mode
      ath6kl: Fix bug in setting dot11_auth_mode in AP mode
      ath6kl: Fix AP mode operation after interface down/up
      ath6kl: Remove modparam multi_norm_if_support
      ath6kl: Find ar->max_norm_iface in firmware IE parsing
      ath6kl: Enable multiple vif support
      ath6kl: Increase the maximum number of connections in AP mode

Venkataraman, Meenakshi (1):
      iwlwifi: Execute runtime calibration always

Wey-Yi Guy (3):
      iwlwifi: deliver hw version in both string and u32 format
      iwlwifi: set hw_version in wiphy
      iwlwifi: use bus_get_hw_id for IWL_TM_CMD_APP2DEV_GET_DEVICE_ID

Yogesh Ashok Powar (2):
      mac80211: Fixing sparse warning at sta_info.c
      mwl8k: Call ieee80211_stop_tx_ba_cb_irqsafe for already deleted BA st=
ream

francesco.gringoli@ing.unibs.it (1):
      b43: avoid packet losses in the dma worker code.

 drivers/bluetooth/btusb.c                          |   10 +-
 drivers/net/wireless/ath/Makefile                  |    1 +
 drivers/net/wireless/ath/ath.h                     |    7 +-
 drivers/net/wireless/ath/ath6kl/Kconfig            |   25 +-
 drivers/net/wireless/ath/ath6kl/Makefile           |   37 +-
 drivers/net/wireless/ath/ath6kl/bmi.c              |  245 +-
 drivers/net/wireless/ath/ath6kl/bmi.h              |    6 -
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  382 ++-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    6 +-
 drivers/net/wireless/ath/ath6kl/common.h           |    1 +
 drivers/net/wireless/ath/ath6kl/core.h             |  109 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |    4 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |    1 +
 drivers/net/wireless/ath/ath6kl/hif-ops.h          |   30 +
 drivers/net/wireless/ath/ath6kl/hif.c              |    5 +
 drivers/net/wireless/ath/ath6kl/hif.h              |    5 +
 drivers/net/wireless/ath/ath6kl/htc.c              |   10 +-
 drivers/net/wireless/ath/ath6kl/init.c             |  380 ++-
 drivers/net/wireless/ath/ath6kl/main.c             |  125 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |  329 ++-
 drivers/net/wireless/ath/ath6kl/target.h           |   16 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |   20 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |  431 ++
 drivers/net/wireless/ath/ath6kl/wmi.c              |  152 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |  143 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    8 +
 drivers/net/wireless/ath/ath9k/ani.c               |   29 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   42 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |  134 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  120 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   76 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   14 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |  275 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   17 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   44 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/beacon.c            |   39 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |   28 +-
 drivers/net/wireless/ath/ath9k/calib.c             |   20 +-
 drivers/net/wireless/ath/ath9k/dfs.c               |    8 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   23 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   17 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   28 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   19 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   51 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |   18 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   25 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   88 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   13 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   89 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   14 +
 drivers/net/wireless/ath/ath9k/init.c              |   13 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   36 +-
 drivers/net/wireless/ath/ath9k/main.c              |  109 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  135 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    7 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   17 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    8 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  118 +-
 drivers/net/wireless/ath/key.c                     |    8 +-
 drivers/net/wireless/b43/b43.h                     |    9 +-
 drivers/net/wireless/b43/dma.c                     |   15 +-
 drivers/net/wireless/b43/main.c                    |   55 +-
 drivers/net/wireless/b43/phy_n.c                   | 4253 ++++++++++------=
----
 drivers/net/wireless/brcm80211/Kconfig             |   18 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   22 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    8 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  135 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   93 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |   42 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   20 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   15 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  423 +--
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |    7 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  325 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |    1 -
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   10 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   28 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   24 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |   20 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  336 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   82 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    9 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h             |   16 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   59 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   79 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   34 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   75 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   29 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   58 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   19 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    5 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    8 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |   14 -
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   88 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |  180 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |   35 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |   13 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |  107 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |  146 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |  151 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   33 +-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |  105 +-
 drivers/net/wireless/iwlwifi/iwl-wifi.h            |   74 +
 drivers/net/wireless/libertas/cfg.c                |   10 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  122 +-
 drivers/net/wireless/mwifiex/fw.h                  |    2 -
 drivers/net/wireless/mwifiex/init.c                |    2 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   11 -
 drivers/net/wireless/mwifiex/join.c                |   14 +-
 drivers/net/wireless/mwifiex/main.h                |    5 +-
 drivers/net/wireless/mwifiex/scan.c                |    8 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   61 -
 drivers/net/wireless/mwl8k.c                       |   14 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    2 +
 drivers/net/wireless/rtlwifi/base.c                |    1 +
 drivers/net/wireless/rtlwifi/ps.c                  |    5 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    1 +
 drivers/net/wireless/wl12xx/cmd.c                  |    3 +
 drivers/net/wireless/wl12xx/event.c                |    2 +-
 drivers/net/wireless/wl12xx/main.c                 |  104 +-
 drivers/net/wireless/wl12xx/ps.c                   |   10 +-
 drivers/net/wireless/wl12xx/scan.c                 |   18 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |    2 +-
 drivers/net/wireless/wl12xx/wl12xx_platform_data.c |   21 +
 include/linux/nl80211.h                            |    2 +
 include/net/bluetooth/bluetooth.h                  |   22 -
 include/net/bluetooth/hci.h                        |   23 +-
 include/net/bluetooth/hci_core.h                   |  280 +-
 include/net/bluetooth/l2cap.h                      |   46 +-
 include/net/bluetooth/mgmt.h                       |  191 +-
 include/net/bluetooth/smp.h                        |    6 +
 include/net/cfg80211.h                             |    7 +-
 include/net/mac80211.h                             |    5 +-
 net/bluetooth/Kconfig                              |   37 +-
 net/bluetooth/Makefile                             |    5 +-
 net/bluetooth/af_bluetooth.c                       |   11 +-
 net/bluetooth/bnep/Kconfig                         |    2 +-
 net/bluetooth/cmtp/Kconfig                         |    2 +-
 net/bluetooth/hci_conn.c                           |  139 +-
 net/bluetooth/hci_core.c                           |  325 +-
 net/bluetooth/hci_event.c                          |  127 +-
 net/bluetooth/hci_sock.c                           |   21 +-
 net/bluetooth/hci_sysfs.c                          |   91 +-
 net/bluetooth/hidp/Kconfig                         |    2 +-
 net/bluetooth/hidp/core.c                          |    4 +-
 net/bluetooth/l2cap_core.c                         |  434 +--
 net/bluetooth/l2cap_sock.c                         |   62 +-
 net/bluetooth/mgmt.c                               |  706 ++--
 net/bluetooth/rfcomm/Kconfig                       |    2 +-
 net/bluetooth/rfcomm/core.c                        |   41 +-
 net/bluetooth/sco.c                                |   42 +-
 net/bluetooth/smp.c                                |  235 +-
 net/mac80211/agg-tx.c                              |   19 +
 net/mac80211/cfg.c                                 |    4 +-
 net/mac80211/mlme.c                                |    8 +
 net/mac80211/rx.c                                  |   65 +-
 net/mac80211/sta_info.c                            |   12 +-
 net/mac80211/sta_info.h                            |    8 +-
 net/nfc/llcp/llcp.c                                |    6 +-
 net/nfc/nfc.h                                      |    4 +-
 net/wireless/nl80211.c                             |    3 +
 179 files changed, 8240 insertions(+), 6795 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath6kl/usb.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-wifi.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPA254AAoJEJctW/TcYTgGU98P/1W9cG1HH3+aqsxL2BsC5rLN
oXiudDlFPzgSxmyhAdKOAoZgpf5LdUguFhsBgOI6LmkCtyjc37m5D+TFbmlgerLB
L1jvHac9X64GKz4BG2GpuyLyCckiD+wFsfI+pn97q0lyh5ibh5sj0zrmnCpWBAqA
EVpkpTQIzgvkoW3kNrp9lntF28U+m9TMKWeCmC0gKWEQwNwIlhWL4EmGdRtGavdD
rT0Lo1TL6KMNDsBN8sHqnggXuYgQsYrrG899O0bYmwvE/HnI1MoWaFd8kAcESzyr
7+qNx7+rEHpzJaAHL3dVAR1G1PNh4Ku2LmlM44zCcOB++JMutilKHrrnhIFgmlt7
TnOBzX0NA4hq6lKWsPIGjWmrgVaFFqHr7k3ADfqXpGb9zvmNGfzIAqQ3rauAFyI3
/+Vd8uZJH8oCTWSYI+rbAMqdsr4ArPkz/Xyr0AgaDIZNifnRxjcaLGfBpgzkvo8/
W7Vp/CVXSVNryC4gGhm0iW/z2dEnLXAgF34XAC24tpSbjdGmBJ/PmWo2Uz1Xingx
fqItmLCKJoZeUCqTJ1GrPtrJ7xBqfS0XckualKh/OtCRsbwKrBeC5SxqJrQFsS6x
zm5x5ug3JWOn1Sbb7FCzWNkh83JScIet2bA7ARguGYdaTesqv9W9tHZGBnhqiEkz
0vubMXBIaxL1v91N1xr5
=4zLi
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
