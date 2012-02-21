From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-02-21
Date: Tue, 21 Feb 2012 15:37:35 -0500
Message-ID: <20120221203734.GD19354@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37847 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab2BUUqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:46:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit a9802d43f205faa2fff422502a1336a50b9615c3

Dave,

Here is a batch of wireless updates intended for 3.4.

Highlights include significant updates to ath6kl, iwlegacy, iwlwifi,
mwifiex, rt2x00, and mac80211.  The bcma and ssb busses get some
attention as well.  There is also a pull of fixes from the wireless
tree, which resolved some merge issues in wireless-next.

Please let me know if there are problems!

Thanks,

John

P.S. "bcma: add PCIe host controller" touches arch/mips.  It reworks
some existing ssb code and adds corresponding bcma code as part of a
larger bcma series.  I neglected to ping Ralf in advance, but I don't
anticipate objection -- I have Cc'ed him just in case I'm wrong...

---

The following changes since commit 0b0a635f79f91f3755b6518627ea06dd0dbfd523:

  bnx2x: update driver version to 1.72.10-0 (2012-02-20 19:34:08 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Alex Yang (1):
      ath6kl: add testmode 2 for 6003 ART

Amit Beka (1):
      iwlwifi: range check to testmode direct reg access

Amitkumar Karwar (5):
      mwifiex: fix NULL pointer dereference in set_channel()
      mwifiex: enable HT operating mode
      mwifiex: cleanup in snmp_mib command preparation code
      mwifiex: update correct dtim_period in dump_station()
      mwifiex: clear previous security setting during association

Andre Guedes (1):
      Bluetooth: Fix potential deadlock

Andrzej Kaczmarek (2):
      Bluetooth: Fix sk_sndtimeo initialization for L2CAP socket
      Bluetooth: l2cap_set_timer needs jiffies as timeout value

Antonio Quartulli (1):
      cfg80211/mac80211: userspace peer authorization in IBSS

Chilam Ng (1):
      ath6kl: initialize the 'nominal_phy' field in the 'wmi_create_pstream=
_cmd' struct for create_qos command

Dan Carpenter (2):
      mac80211: off by one in mcs mask handling
      ath9k: cleanup a min_t() cast

Daniel Wagner (1):
      Bluetooth: Don't mark non xfer isoc endpoint URBs with URB_ISO_ASAP

David Gibson (1):
      orinoco: Remove old mailing lists from MAINTAINERS

Devendra.Naga (1):
      rtlwifi: remove return in _rtl_pci_switch_clk_req

Don Fry (3):
      iwlwifi: clarify comment
      iwlwifi: move bcast_sta_id init to common routine
      iwlwifi: move all ucode routines to iwl-ucode.c

Eliad Peller (1):
      mac80211: support hw scan while idle

Emmanuel Grumbach (22):
      iwlwifi: add fw_alive to transport layer API, kill tx_start
      iwlwifi: separate the APM from the EEPROM
      iwlwifi: move the shrd memory from priv
      iwlwifi: allocate the transport from the bus layer
      iwlwifi: move the bus configuration to transport
      iwlwifi: the read / write register ops move to transport
      iwlwifi: give trans to all the read / write functions
      iwlwifi: remove the pointer to dev from the bus layer
      iwlwifi: don't use the bus for ucode fw_desc any more
      iwlwifi: rename trans_ops->request_irq to trans_ops->start_hw
      iwlwifi: move prepare_card_hw to start_hw
      iwlwifi: move apm_init to start_hw
      iwlwifi: introduce trans_ops->stop_hw
      iwlwifi: move the RF kill logic from iwl_probe to transport
      iwlwifi: consolidate the start_device flow
      iwlwifi: kill bus_apm_config
      iwlwifi: kill bus_is_pm_supported
      iwlwifi: kill bus_get_hw_id_string
      iwlwifi: kill bus_get_hw_id
      iwlwifi: move hw_rev to transport layer
      iwlwifi: stop_hw replace enable_rfkill_int
      iwlwifi: debug print in tx_queue_set_status is more clear

Felix Fietkau (3):
      mac80211: add #ifdef CONFIG_MAC80211_VERBOSE_DEBUG for a debug printk
      mac80211: do not call rate control .tx_status before .rate_init
      mac80211: do not call rate control .tx_status before .rate_init

Gertjan van Wingerde (8):
      rt2x00: Introduce concept of driver data in struct rt2x00_dev.
      rt2x00: Use struct rt2x00_dev driver data in rt2800{pci,usb}.
      rt2x00: Update comment on freq_offset field in struct rt2x00_dev.
      rt2x00: Use saved BBP 25 and 26 values when configuring channel on RT=
3572.
      rt2x00: Fix RFCSR 12 & 13 programming on RT3572 channel switching.
      rt2x00: Align RT3572 channel switch RFCSR 1 programming with Ralink d=
river.
      rt2x00: Fix RT3572 channel switch RFCSR 7 programming.
      rt2x00: Correctly set txmixer_gain in RT3572 channel switching.

Gregory Greenman (1):
      iwlwifi: Connect IDI transport to driver.

Hauke Mehrtens (10):
      bcma: add the core unit number
      bcma: add constants for PCI and use them
      bcma: export bcma_pcie_read()
      bcma: make some functions __devinit
      bcma: add PCIe host controller
      bcma: add bus num counter
      bcma: add extra sprom check
      bcma: log the id, rev and pkg of the chip found
      ssb: log the id, rev and pkg of the chip found
      ssb: add support for bcm5354

Johan Hedberg (2):
      Bluetooth: Remove bogus inline declaration from l2cap_chan_connect
      Bluetooth: Add missing QUIRK_NO_RESET test to hci_dev_do_close

Johannes Berg (15):
      iwlwifi: fix uCode event tracing
      iwlwifi: always restrict scan dwell in P2P
      iwlwifi: release IRQ in error path
      mac80211: move managed mode station state modification
      mac80211: simplify AP_VLAN handling
      mac80211: dont program keys for stations not uploaded
      mac80211: add NOTEXIST station state
      mac80211: add sta_state callback
      mac80211: implement sta_add/sta_remove in sta_state
      mac80211: remove dummy STA support
      cfg80211: stop tracking authenticated state
      cfg80211: export cfg80211_ref_bss
      mac80211: redesign auth/assoc
      mac80211: call rate control only after init
      mac80211: call rate control only after init

John W. Linville (6):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/iwlw=
ifi
      rtlwifi: Modify rtl_pci_init to return 0 on success
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (3):
      ath6kl: Fix connect command to clear previously used IEs
      ath6kl: Add del_station cfg80211_ops
      ath6kl: Advertise TX/RX support for frames in AP mode

Kalle Valo (16):
      ath6kl: handle firmware names more dynamically
      ath6kl: add support for FW API 3
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: use netdev_features_t
      ath6kl: remove -D__CHECK_ENDIAN__ from Makefile
      ath6kl: fix uninitialized warning in ath6kl_process_uapsdq()
      ath6kl: rename vif init and cleanup functions
      ath6kl: unify cfg80211 init/cleanup functions
      ath6kl: add ATH6KL_CONF_UART_DEBUG
      ath6kl: create core.c
      ath6kl: get rid of AR_DBG_LVL_CHECK()
      ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump() into functions
      ath6kl: create ath6kl_core.ko
      ath6kl: add back beginnings of USB support
      ath6kl: fix testmode when fw-2.bin or fw-3.bin is used
      ath6kl: fix compiler warning in ath6kl_init_hw_params()

Kenny Hsu (4):
      iwlwifi: update testmode command of direct register access
      iwlwifi: enhance testmode command sram_read
      iwlwifi: update error dump in testmode command sram_read
      iwlwifi: add testmode cmd IWL_TM_CMD_APP2DEV_GET_FW_INFO

Larry Finger (1):
      rtlwifi: Remove extra debugging message accidentally left in

Luis R. Rodriguez (1):
      mac80211: rename mesh static path_lookup()

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c 21f3) for BCM20702A0

Masanari Iida (4):
      ath6kl: Fix typo in cfg80211.c
      net: Fix typo in ipw2x00/libipw_rx.c
      iwmc3200wifi: Fix typo in trace.h
      rtlwifi: Fix typo in dm.c

Octavian Purdila (2):
      Bluetooth: silence lockdep warning
      Bluetooth: Fix RFCOMM session reference counting issue

Pavel Roskin (1):
      ath9k: stop on rates with idx -1 in ath9k rate control's .tx_status

Peter Hurley (1):
      Bluetooth: Fix l2cap conn failures for ssp devices

Raja Mani (7):
      ath6kl: Avoid taking struct as argument in ath6kl_wmi_set_ip_cmd
      ath6kl: Send own IP addr to the firmware during WOW suspend
      ath6kl: Remove useless initialization in ath6kl_read_fwlogs()
      ath6kl: Re-architect suspend mode handling in ath6kl_sdio_suspend
      ath6kl: Configure WOW patterns while going to wow_suspend
      ath6kl: Wait for host sleep mode cmd processed event during WOW suspe=
nd
      ath6kl: Return a proper error code when not in connected state

Rishi Panjwani (1):
      ath6kl: Support for TCP checksum offload to firmware

Santosh Sajjan (1):
      ath6kl: Workaround to support Deep Sleep with MSM.

Simon Graham (2):
      rtlwifi: Handle previous allocation failures when freeing device memo=
ry
      rtlwifi: Return correct failure code on error

Stanislaw Gruszka (30):
      rt2800: radio 3xxx: reprogram only lower bits of RF_R3
      rt2800: radio 3xxx: program RF_R1 during channel switch
      rt2800: radio 3xxx: add channel switch calibration routines
      rt2800: radio 3xxxx: channel switch RX/TX calibration fixes
      rt2800: document RF_R03 register bits [7:4]
      iwlegacy: move rxon commands out of ctx structure
      iwlegacy: get rid of ctx->rxon_cmd
      iwlegacy: get rid of ctx->rxon_timing_cmd
      iwlegacy: get rid of rxon_assoc_cmd
      iwlegacy: get rid of qos_cmd
      iwlegacy: get rid of wep_key_cmd
      iwlegacy: get rid of ap_sta_id
      iwlegacy: move bcast_sta_id to hw_params
      iwlegacy: get rid of *_devtype
      iwlegacy: get rid of ctxid
      iwlegacy: get rid of mcast_queue
      iwlegacy: move wep_keys out of context
      iwlegacy: get rid of ctx->station_flags
      iwlegacy: remove ctx interface_modes
      iwlegacy: move qos_data out of ctx structure
      iwlegacy: move ht out of ctx structure
      iwlegacy: get rid of ctx->ac_to_fifo
      iwlegacy: get rid of ctx->ac_to_queue
      iwlegacy: get rid of ctx->is_active
      iwlegacy: remove il_setup_interface()
      iwlegacy: get rid of ctx structure
      iwlegacy: move ops out of config
      iwlegacy: merge il_base_params into il_cfg
      iwlegacy: remove struct il_tx_info
      iwlegacy: remove set_hw_params callback

Stephen Hemminger (1):
      ath6kl: make net_device_ops const

Sujith Manoharan (5):
      ath6kl: Fix panic when setting a channel
      ath6kl: Fix SDIO error path
      ath6kl: Remove redundant pointer check
      ath6kl: Initialize a variable properly
      ath6kl: Fix listen interval handling

Thirumalai Pachamuthu (1):
      ath6kl: Add support for uAPSD

Thomas Pedersen (1):
      ath6kl: send TCMD response through testmode events

Tim Gardner (1):
      rtlwifi: Fix PCI probe error path orphaned memory

Ulisses Furquim (2):
      Bluetooth: Remove usage of __cancel_delayed_work()
      Bluetooth: Fix possible use after free in delete path

Vasanthakumar Thiagarajan (16):
      ath6kl: Use cfg80211_roamed_bss() to report roaming event
      ath6kl: Remove few unnecessary spin_locks around set_bit()
      ath6kl: Add a module parameter to enable uart debug
      ath6kl: Add a function in wmi to send WMI_MCAST_FILTER_CMDID
      ath6kl: Add a function in wmi.c to add/delete a multicast filter
      ath6kl: Implement ndo_set_rx_mode()
      ath6kl: Remove deadcode in main.c
      ath6kl: Change ielen in ath6kl_add_new_sta() from u8 to size_t
      ath6kl: Use a mutex_lock to avoid race in diabling and handling irq
      ath6kl: Make sure to delete rx aggregation timer in aggr_reset_state()
      ath6kl: Fix memory leak when unloading ath6kl_sdio
      ath6kl: Define a structure for connection specific aggregation inform=
ation
      ath6kl: Pass vif instead of ar to ath6kl_add_new_sta()
      ath6kl: Fix bug in using tid given by addba/delba req events
      ath6kl: Fix bug in maintaining aggregation state in AP mode
      ath6kl: Fix kernel panic during rx aggregation

Vinicius Costa Gomes (1):
      Bluetooth: Fix using an absolute timeout on hci_conn_put()

Vivek Natarajan (1):
      ath6kl: Remove redundant key_index check.

Wey-Yi Guy (7):
      iwlwifi: don't process the info from uCode if does not has ownership
      iwlwifi: Sanity check for sta_id
      iwlwifi: update Copyright
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next
      iwlwifi: fix typo
      iwlwifi: add option to disalbe LED
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into wireless-next

Yogesh Ashok Powar (1):
      mwl8k: Remove BSSID from the firmware when the BSS is stopped

 Documentation/DocBook/80211.tmpl                  |    1 -
 MAINTAINERS                                       |    2 -
 arch/mips/pci/pci-bcm47xx.c                       |   49 +-
 drivers/bcma/bcma_private.h                       |    8 +-
 drivers/bcma/driver_pci.c                         |  168 ++--
 drivers/bcma/driver_pci_host.c                    |  578 +++++++++-
 drivers/bcma/host_pci.c                           |    4 +-
 drivers/bcma/main.c                               |   14 +-
 drivers/bcma/scan.c                               |   24 +-
 drivers/bcma/sprom.c                              |    7 +
 drivers/bluetooth/btusb.c                         |    4 +-
 drivers/net/wireless/ath/ath6kl/Kconfig           |   25 +-
 drivers/net/wireless/ath/ath6kl/Makefile          |   30 +-
 drivers/net/wireless/ath/ath6kl/bmi.c             |   10 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c        |  606 ++++++---
 drivers/net/wireless/ath/ath6kl/cfg80211.h        |   12 +-
 drivers/net/wireless/ath/ath6kl/common.h          |    3 -
 drivers/net/wireless/ath/ath6kl/core.c            |  316 +++++
 drivers/net/wireless/ath/ath6kl/core.h            |  107 ++-
 drivers/net/wireless/ath/ath6kl/debug.c           |  114 +-
 drivers/net/wireless/ath/ath6kl/debug.h           |   28 +-
 drivers/net/wireless/ath/ath6kl/hif.c             |   15 +-
 drivers/net/wireless/ath/ath6kl/htc.c             |   11 +-
 drivers/net/wireless/ath/ath6kl/init.c            |  472 +++----
 drivers/net/wireless/ath/ath6kl/main.c            |  182 +++-
 drivers/net/wireless/ath/ath6kl/sdio.c            |  140 ++-
 drivers/net/wireless/ath/ath6kl/testmode.c        |  102 +--
 drivers/net/wireless/ath/ath6kl/testmode.h        |    6 +-
 drivers/net/wireless/ath/ath6kl/txrx.c            |  534 ++++++--
 drivers/net/wireless/ath/ath6kl/usb.c             |  431 +++++++
 drivers/net/wireless/ath/ath6kl/wmi.c             |  148 ++-
 drivers/net/wireless/ath/ath6kl/wmi.h             |   67 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c          |    2 +-
 drivers/net/wireless/ath/ath9k/rc.c               |    2 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c          |    2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c          |  186 ++--
 drivers/net/wireless/iwlegacy/3945-rs.c           |    7 +-
 drivers/net/wireless/iwlegacy/3945.c              |  111 +-
 drivers/net/wireless/iwlegacy/3945.h              |    6 +-
 drivers/net/wireless/iwlegacy/4965-calib.c        |   24 +-
 drivers/net/wireless/iwlegacy/4965-mac.c          |  512 ++++----
 drivers/net/wireless/iwlegacy/4965-rs.c           |   48 +-
 drivers/net/wireless/iwlegacy/4965.c              |  328 ++----
 drivers/net/wireless/iwlegacy/4965.h              |   22 +-
 drivers/net/wireless/iwlegacy/common.c            |  656 ++++------
 drivers/net/wireless/iwlegacy/common.h            |  234 ++---
 drivers/net/wireless/iwlegacy/debug.c             |   43 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c           |    6 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |    6 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c           |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  713 +----------
 drivers/net/wireless/iwlwifi/iwl-agn.h            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-bus.h            |   64 -
 drivers/net/wireless/iwlwifi/iwl-core.c           |  128 +--
 drivers/net/wireless/iwlwifi/iwl-core.h           |    6 -
 drivers/net/wireless/iwlwifi/iwl-debug.h          |   16 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h            |  109 --
 drivers/net/wireless/iwlwifi/iwl-eeprom.c         |   65 +-
 drivers/net/wireless/iwlwifi/iwl-io.c             |  193 ++--
 drivers/net/wireless/iwlwifi/iwl-io.h             |   60 +-
 drivers/net/wireless/iwlwifi/iwl-led.c            |    9 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c       |   36 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c            |  229 +---
 drivers/net/wireless/iwlwifi/iwl-power.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h         |    2 -
 drivers/net/wireless/iwlwifi/iwl-testmode.c       |   36 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h |   18 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c  |  103 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c  |   55 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c     |  661 ++++++++--
 drivers/net/wireless/iwlwifi/iwl-trans.h          |  133 ++-
 drivers/net/wireless/iwlwifi/iwl-ucode.c          |  740 ++++++++++--
 drivers/net/wireless/iwlwifi/iwl-ucode.h          |  178 +++
 drivers/net/wireless/iwmc3200wifi/trace.h         |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c           |   23 +-
 drivers/net/wireless/mwifiex/init.c               |    1 +
 drivers/net/wireless/mwifiex/main.h               |    2 +-
 drivers/net/wireless/mwifiex/scan.c               |    6 -
 drivers/net/wireless/mwifiex/sta_cmd.c            |   60 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c        |    3 +
 drivers/net/wireless/mwl8k.c                      |   38 +-
 drivers/net/wireless/rt2x00/rt2800.h              |   49 +-
 drivers/net/wireless/rt2x00/rt2800lib.c           |  159 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c           |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h              |   15 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c           |   18 +
 drivers/net/wireless/rtlwifi/core.c               |    4 +-
 drivers/net/wireless/rtlwifi/pci.c                |   39 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       |    2 +-
 drivers/ssb/driver_chipcommon_pmu.c               |   48 +-
 drivers/ssb/driver_mipscore.c                     |    3 +
 drivers/ssb/main.c                                |    3 +
 drivers/ssb/scan.c                                |    3 +
 drivers/ssb/ssb_private.h                         |    4 +
 include/linux/bcma/bcma.h                         |    2 +
 include/linux/bcma/bcma_driver_chipcommon.h       |   16 +
 include/linux/bcma/bcma_driver_pci.h              |  125 ++-
 include/linux/bcma/bcma_regs.h                    |   27 +
 include/net/bluetooth/bluetooth.h                 |    2 +
 include/net/bluetooth/hci_core.h                  |    6 +-
 include/net/bluetooth/l2cap.h                     |   12 +-
 include/net/cfg80211.h                            |   58 +-
 include/net/mac80211.h                            |   35 +
 net/bluetooth/af_bluetooth.c                      |   12 +-
 net/bluetooth/hci_conn.c                          |    4 +
 net/bluetooth/hci_core.c                          |    3 +-
 net/bluetooth/l2cap_core.c                        |   24 +-
 net/bluetooth/l2cap_sock.c                        |    4 +-
 net/bluetooth/rfcomm/core.c                       |   18 +-
 net/bluetooth/rfcomm/sock.c                       |    2 +
 net/mac80211/Makefile                             |    4 +-
 net/mac80211/cfg.c                                |    6 +-
 net/mac80211/debugfs.c                            |    2 +
 net/mac80211/debugfs_sta.c                        |    4 +-
 net/mac80211/driver-ops.h                         |   33 +
 net/mac80211/driver-trace.h                       |   32 +
 net/mac80211/ibss.c                               |    6 +-
 net/mac80211/ieee80211_i.h                        |   79 +-
 net/mac80211/iface.c                              |    7 +-
 net/mac80211/key.c                                |   38 +-
 net/mac80211/main.c                               |   16 +-
 net/mac80211/mesh_pathtbl.c                       |    6 +-
 net/mac80211/mlme.c                               | 1390 +++++++++++++++--=
----
 net/mac80211/pm.c                                 |   11 +-
 net/mac80211/rate.c                               |    4 +-
 net/mac80211/rate.h                               |    3 +-
 net/mac80211/rx.c                                 |   22 +-
 net/mac80211/sta_info.c                           |  252 ++--
 net/mac80211/sta_info.h                           |   40 +-
 net/mac80211/util.c                               |   11 +-
 net/mac80211/work.c                               |  815 ------------
 net/wireless/core.h                               |   14 +-
 net/wireless/mlme.c                               |  322 +----
 net/wireless/nl80211.c                            |   40 +-
 net/wireless/scan.c                               |   12 +
 net/wireless/sme.c                                |   41 +-
 141 files changed, 7962 insertions(+), 6096 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath6kl/core.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/usb.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-ucode.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIbBAEBAgAGBQJPRACOAAoJEJctW/TcYTgGXkQP+M2P0aAlw9vWtZZx94UzzDwU
mS2CjOeD1iZbmFumLmB7+u2ZGzb9g15CtC96EacHH8Nl530grreVipDTdX7yOmVX
L+Xh6oKojMjBfZmB4LnepmwLm3Tgs43bhGJ5z4jQ+1kzGsG/te4O5eQmou5S6xSX
pczT9eZfuVyd/aKrHAFPEN2+emTv44dVmZsAaZ5Hlmi6M9CCJBBT4Dp7V7Re9Z0Q
rUCiy/cKgXFWE+f0DYKLyOib3N9pNR2hBrYJDOMGWfJ8lLVRG93igTNYCHVrsxfQ
6nQFxv2rElthGSBunQYXy7qdKgg0remVFme/FI8OjXcvgscSc+pNp+WmlHDIvXEh
WPqWrVvg8ekDivtpTU3WzzFJSgk4SLYEVUuwPnhUTl7U9h5x3BZHLcePkItbtBMi
58MNsJ6+zA3IkOSCiJm4szv6WvdNGaE2a1Izsq5zSYbOB7xQt+eNSeDvPDEB/ebM
jk0cWP99hYG4KFcgnUcoMwygdlzXzH2QsWYv+7pEu3rW3kTuolrJ/DD3iWq9/D1S
HAqoXPARYzX/kaDOcEV/txoHNeIs8vhYHQ4FtT8VH/E4QHKVE77NiUsUQSdXiCKt
SIjhQWOBhbizICDLKSvEGmYMNrq7DRtu+vbi5hGwuBLwNWmwgAaq40JVPYVRU69N
7dvn6ZXBsALK+C+vVqw=
=VnWG
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
