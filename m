From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-09-08
Date: Mon, 8 Sep 2014 15:16:31 -0400
Message-ID: <20140908191630.GB29412@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35003 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbaIHTaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 15:30:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.18 stream...

For the mac80211 bits, Johannes says:

"Not that much content this time. Some RCU cleanups, crypto
performance improvements, and various patches all over,
rather than listing them one might as well look into the
git log instead."

For the Bluetooth bits, Gustavo says:

"The changes consists of:

        - Coding style fixes to HCI drivers
        - Corrupted ack value fix for the H5 HCI driver
        - A couple of Enhanced L2CAP fixes
        - Conversion of SMP code to use common L2CAP channel API
        - Page scan optimizations when using the kernel-side whitelist
        - Various mac802154 and and ieee802154 6lowpan cleanups
        - One new Atheros USB ID"

For the iwlwifi bits, Emmanuel says:

"We have a new big thing coming up which is called Dynamic Queue
Allocation (or DQA).  This is a completely new way to work with the
Tx queues and it requires major refactoring.  This is being done by
Johannes and Avri.  Besides this, Johannes disables U-APSD by default
because of APs that would disable A-MPDU if the association supports
U-ASPD.  Luca contributed to the power area which he was cleaning
up on the way while working on CSA.  A few more random things here
and there."

For the Atheros bits, Kalle says:

"For ath6kl we had two small fixes and a new SDIO device id.

For ath10k the bigger changes are:

 * support for new firmware version 10.2 (Michal)

 * spectral scan support (Simon, Sven & Mathias)

 * export a firmware crash dump file (Ben & me)

 * cleaning up of pci.c (Michal)

 * print pci id in all messages, which causes most of the churn (Michal)"

Beyond that, we have the usual collection of various updates to ath9k,
b43, mwifiex, and wil6210, as well as a few other bits here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1bd3fa7b8c9b2936c16c6e6452f9cc991c405872:

  Merge branch 'for-john' of git://git.kernel.org/pub/scm/linux/kernel/git/=
iwlwifi/iwlwifi-fixes (2014-09-04 13:12:02 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-09-08

for you to fetch changes up to 61a3d4f9d52c00b2016bc27fc66b10a194043f76:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless (2014-09-08 11:14:56 -0400)

----------------------------------------------------------------

Alexander Aring (1):
      ieee802154: 6lowpan: remove unused function

Amitkumar Karwar (3):
      mwifiex: fix left_len calculation issue
      mwifiex: rename macro and variables related to API revision
      mwifiex: use firmware API revision from GET_HW_SPEC response

Andreea-Cristina Bernat (4):
      mac80211: scan: Replace rcu_assign_pointer() with RCU_INIT_POINTER()
      mac80211: Replace rcu_dereference() with rcu_access_pointer()
      carl9170: Remove redundant protection check
      carl9170: tx: Replace rcu_assign_pointer() with RCU_INIT_POINTER()

Andrei Otcheretianski (1):
      ieee80211: Support parsing TPC report element in action frames

Avri Altman (2):
      iwlwifi: consolidate hw scheduler configuration code
      iwlwifi: trans: configure the scheduler enable register

Ben Greear (4):
      ath10k: improve 'hard' simulate fw crash
      ath10k: improve vdev map handling
      ath10k: fix typo in error message
      ath10k: provide firmware crash info via debugfs

Bob Copeland (4):
      mac80211: mesh_plink: use get_unaligned_le16 instead of memcpy
      ath5k: drop useless comparison
      ath5k: ensure led name is null terminated
      ath5k: remove redundant null check before kfree()

Canek Pel=C3=A1ez Vald=C3=A9s (1):
      rt2x00: support Ralink 5362.

Csaba Kiraly (1):
      ath9k_htc: advertise support for TDLS

Dan Carpenter (1):
      MAINTAINTERS: The NFC list is subscribers-only

David Spinadel (1):
      iwlwifi: mvm: enable passive fragmented scan changes

Dedy Lansky (1):
      wil6210: Limit max number of associated stations

Eliad Peller (3):
      mac80211: disable 40MHz support in case of 20MHz AP
      iwlwifi: mvm: add use_ps-poll debugfs power option
      iwlwifi: mvm: clear d0i3 state on recovery

Emmanuel Grumbach (3):
      iwlwifi: mvm: reduce the AMPDU size in low latency mode
      iwlwifi: mvm: use dynamic SMPS for P2P Client
      iwlwifi: mvm: force protection for P2P

Eran Harary (2):
      iwlwifi: mvm: fix the dump_umac_error_log
      iwlwifi: mvm: fix comment typo

Eyal Shapira (1):
      iwlwifi: mvm: disable tx aggregation on low latency vifs

Hans Wennborg (2):
      ath6kl: fix %d confusingly prefixed with 0x in format strings
      mwifiex: fix decimal printf format specifiers prefixed with 0x

Hauke Mehrtens (1):
      bcma: only map wrapper if its address is available

Himangi Saraogi (10):
      ath6kl: convert a driver to use module_usb_driver()
      Bluetooth: Remove typedef bluecard_info_t
      Bluetooth: Remove typedef btuart_info_t
      Bluetooth: Remove typedefs nsh_t and dtl1_info_t
      Bluetooth: Remove typedef bt3c_info_t
      net: wireless: wl1251: Remove unnecessary free_irq
      cw1200: Introduce the use of devm_kzalloc
      wireless: wlcore: Use devm_kzalloc
      atmel_cs: Remove typedef local_info_t
      orinoco_usb: use USB API functions rather than constants

Ido Yariv (2):
      mac80211: Fix accounting of the tailroom-needed counter
      mac80211: don't resize skbs needlessly

Jade Bilkey (1):
      ath5k: added debugfs file for dumping eeprom

Janusz Dziedzic (1):
      ath10k: extend debug code for RX path

Johan Hedberg (35):
      Bluetooth: Add convenience function to check for pending power off
      Bluetooth: Create unified helper function for updating page scan
      Bluetooth: Disable page scan if all whitelisted devices are connected
      Bluetooth: Remove redundant check for remote_key_dist
      Bluetooth: Fix confusion between parent and child channel for 6lowpan
      Bluetooth: Fix reference counting of global L2CAP channels
      Bluetooth: Fix __l2cap_no_conn_pending() usage with all channels
      Bluetooth: Resume BT_CONNECTED state after LE security elevation
      Bluetooth: Remove special handling of ATT in l2cap_security_cfm()
      Bluetooth: Refactor l2cap_connect_cfm
      Bluetooth: Move L2CAP fixed channel creation into l2cap_conn_cfm
      Bluetooth: Improve fixed channel lookup based on link type
      Bluetooth: Remove special ATT data channel handling
      Bluetooth: Move parts of fixed channel initialization to l2cap_add_sc=
id
      Bluetooth: Call L2CAP teardown callback before clearing chan->conn
      Bluetooth: Call l2cap_le_conn_ready after notifying channels
      Bluetooth: Fix using HCI_CONN_LE_SMP_PEND to check for SMP context
      Bluetooth: Fix hci_update_random_address() error return for no crypto
      Bluetooth: Fix IRK lookup when tfm_aes is not available
      Bluetooth: Refactor SMP (de)initialization into separate functions
      Bluetooth: Move SMP initialization after HCI init
      Bluetooth: Move SMP (de)initialization to smp.c
      Bluetooth: Add more L2CAP convenience callbacks
      Bluetooth: Add SMP L2CAP channel skeleton
      Bluetooth: Make AES crypto context private to SMP
      Bluetooth: Convert SMP to use l2cap_chan infrastructure
      Bluetooth: Use L2CAP resume callback to call smp_distribute_keys
      Bluetooth: Add public l2cap_conn_shutdown() API to request disconnect=
ion
      Bluetooth: Call l2cap_conn_shutdown() when SMP recv callback fails
      Bluetooth: Fix double free of SMP data skb
      Bluetooth: Add SMP-internal timeout callback
      Bluetooth: Remove unused l2cap_conn->security_timer
      Bluetooth: Move canceling security_timer into smp_chan_destroy()
      Bluetooth: Always call smp_distribute_keys() from a workqueue
      Bluetooth: Make smp_chan_destroy() private to smp.c

Johannes Berg (18):
      mac80211: don't duplicate station QoS capability data
      mac80211: make ieee80211_vif_use_reserved_switch static
      cfg80211: clarify BSS probe response vs. beacon data
      cfg80211: allow passing frame type to cfg80211_inform_bss()
      iwlwifi: make U-APSD default configurable at compile time
      iwlwifi: trans: refactor txq_enable arguments
      iwlwifi: mvm: add some debugging to quota allocation
      iwlwifi: don't export tracepoints unnecessarily
      iwlwifi: trans: allow skipping scheduler hardware config
      iwlwifi: trans: make aggregation explicit for TX queue handling
      iwlwifi: add Intel Mobile Communications copyright
      iwlwifi: mvm: correct firmware disassoc command sequence
      iwlwifi: mvm: clean up FIFO definitions
      iwlwifi: mvm: clarify stop_count, remove transport_stopped
      iwlwifi: mvm: use tdls indication from mac80211
      iwlwifi: mvm: use iwl_mvm_mac_get_queues_mask() more
      iwlwifi: mvm: clean up broadcast station handling
      iwlwifi: mvm: clean up AUX station handling

John W. Linville (5):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge tag 'mac80211-next-for-john-2014-08-29' of git://git.kernel.org=
/.../jberg/mac80211-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Kalle Valo (3):
      ath10k: add ath10k_pci_diag_* helpers
      ath10k: rename ath10k_pci_hif_dump_area() to ath10k_pci_fw_crashed_du=
mp()
      ath10k: print more driver info when firmware crashes

Liad Kaufman (1):
      iwlwifi: mvm: wait for TE notif when protecting TDLS session

Loic Poulain (1):
      Bluetooth: Fix HCI H5 corrupted ack value

Luciano Coelho (8):
      iwlwifi: mvm: reset the temperature when temperature test is disabled
      iwlwifi: mvm: don't run automatic checks if CT was caused by debugfs
      iwlwifi: mvm: add debugfs entry for ps_disabled
      iwlwifi: mvm: re-enable ps when monitor interfaces are removed
      iwlwifi: mvm: refactor iwl_mvm_power_set_pm() to spin the ps part off
      iwlwifi: mvm: add function to update only ps
      iwlwifi: mvm: add option that allows a vif to disable PS
      iwlwifi: mvm: set the TX disable bit when doing a chanctx switch

Lukasz Rymanowski (2):
      Bluetooth: Improve data packing in SAR mode
      Bluetooth: Fix ERTM L2CAP resend packet

Matti Gottlieb (2):
      iwlwifi: mvm: Add set NIC temperature debug option
      iwlwifi: mvm: Add marker command 0xcb

Michal Kazior (30):
      ath10k: add support for 10.2 firmware
      ath10k: fix aggregated 4addr Rx
      ath10k: improve channel switching
      ath10k: fix wmi service bitmap debug
      ath10k: simplify scan debug prints
      ath10k: introduce a stricter scan state machine
      ath10k: embed ar_pci inside ar
      ath10k: remove target soc ps code
      ath10k: remove pci features var
      ath10k: group some pci probing helpers
      ath10k: remove htc->stopped
      ath10k: fix a conflict bug in wmi service bitmap
      ath10k: move fw init print
      ath10k: fix legacy irq workaround
      ath10k: setup irq method in probe
      ath10k: split ce irq/handler setup
      ath10k: make sure to really disable irqs
      ath10k: remove early irq handling
      ath10k: rework posting pci rx buffers
      ath10k: update comment regarding warm reset
      ath10k: ignore ar_pci->started in pipe cleanup
      ath10k: remove ar_pci->started
      ath10k: flush hif buffers before recovery
      cfg80211: re-enable CSA for drivers that support it
      ath10k: improve logging to include dev id
      ath10k: fix fw crash dumping
      ath10k: move pci init structures
      ath10k: dont duplicate service-pipe mapping
      ath10k: make target endianess more explicit
      mac80211: fix chantype recalc warning

Mika Westerberg (1):
      net: rfkill: gpio: Add more Broadcom bluetooth ACPI IDs

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: update flushing many writes performed in a row
      b43: don't duplicate common PHY read/write ops
      b43: flush some writes on Broadcom MIPS SoCs
      b43: N-PHY: update rev3+ gain control workarounds
      b43: N-PHY: add RF power tables for radio 0x2057 revs 9 & 14
      b43: implement PPR (Power Per Rate) management/API
      b43: N-PHY: support setting custom TX power
      bcma: get info about flash type SoC booted from

Rasmus Villemoes (1):
      ray_cs: Add include guards

Rickard Strandqvist (1):
      net: wireless: ipw2x00: ipw2200.c: Cleaning up missing null-terminate=
 in conjunction with strncpy

Simon Wunderlich (2):
      ath10k: add spectral scan feature
      ath10k: unregister spectral before mac

Srinivas Kandagatla (1):
      ath6kl: Add SDIO device ID for QCA6234X Support

Sujith Manoharan (37):
      ath9k: Add a debug level for channel context
      ath9k: Handle failure to allocate HW timer
      ath9k: Move channel operations to channel.c
      ath9k: Add debug information
      ath9k: Add a config option for channel context
      ath9k: Move P2P functions to channel.c
      ath9k: Isolate P2P powersave routines
      ath9k: Isolate ath9k_use_chanctx module parameter
      ath9k: Add a routine for initializing channel contexts
      ath9k: Add a routine to tear down channel contexts
      ath9k: Make ath_chanctx_work static
      ath9k: Cleanup mgd_prepare_tx callback
      ath9k: Conditionally compile a few functions
      ath9k: Exclude more functions
      ath9k: Conditionally compile more functions
      ath9k: Make ath_chanctx_offchan_switch static
      ath9k: Make ath_chanctx_get_oper_chan static
      ath9k: Make ath_chanctx_switch static
      ath9k: Fix channel context events
      ath9k: Fix function declarations
      ath9k: Add wrappers for beacon events
      ath9k: Add ath9k_chanctx_wake_queues
      ath9k: Add ath9k_offchannel_init
      ath9k: Use ath_chanctx_check_active properly
      ath9k: Fix function argument type
      ath9k: Fix 'offchannel' in ath_softc
      ath9k: Fix channel context variables in ath_softc
      ath9k: Remove redundant ifdef
      ath9k: Move ath9k_beacon_add_noa to channel.c
      ath9k: Fix ath_chanctx_get()
      ath9k: Add new chanctx events
      ath9k: Print the event/state in ath_chanctx_event
      ath9k: Fix interface limits
      ath9k: Fix channel context creation
      ath9k: Disable fastcc for channel context mode
      ath9k: Add more debug statements for channel context
      ath9k: Fix channel context timer

Sven Eckelmann (1):
      ath: Move spectral debugfs structs to shared header

Tomasz Bursztyka (1):
      wireless: core: Reorder wiphy_register() notifications relevantly

Varka Bhadram (4):
      MAINTAINERS: update maintainers info
      mac802154: cleanup in rx path
      mac802154: common error path
      mac802154: common tx error path

Vincent Zwanenburg (1):
      Add a new PID/VID 0227/0930 for AR3012.

Vladimir Kondratiev (13):
      wil6210: map MAC timer for packet lifetime into debugfs
      wil6210: fix race in reset
      wil6210: update copyright year 2014
      wil6210: check error in wil_target_reset()
      wil6210: wait longer for hardware reset completion
      wil6210: Workaround for Sparrow with bad device id
      wil6210: convert debugfs to the table mode
      wil6210: fix beamforming data reporting
      wil6210: fix false "scan timeout"
      wil6210: fix free'd memory access in wil_if_free()
      wil6210: cfg80211_rx_mgmt to use GFP_ATOMIC
      wil6210: fix access after free in wil_pcie_remove()
      cfg80211: remove @gfp parameter from cfg80211_rx_mgmt()

 MAINTAINERS                                        |   11 +-
 drivers/bcma/driver_mips.c                         |   62 +
 drivers/bcma/host_soc.c                            |    4 +
 drivers/bcma/scan.c                                |   11 +-
 drivers/bluetooth/ath3k.c                          |    2 +
 drivers/bluetooth/bluecard_cs.c                    |   35 +-
 drivers/bluetooth/bt3c_cs.c                        |   27 +-
 drivers/bluetooth/btuart_cs.c                      |   27 +-
 drivers/bluetooth/btusb.c                          |    1 +
 drivers/bluetooth/dtl1_cs.c                        |   36 +-
 drivers/bluetooth/hci_h5.c                         |    2 +-
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath10k/Kconfig            |    1 +
 drivers/net/wireless/ath/ath10k/Makefile           |    1 +
 drivers/net/wireless/ath/ath10k/bmi.c              |   52 +-
 drivers/net/wireless/ath/ath10k/ce.c               |  185 +--
 drivers/net/wireless/ath/ath10k/ce.h               |   28 +-
 drivers/net/wireless/ath/ath10k/core.c             |  246 ++--
 drivers/net/wireless/ath/ath10k/core.h             |   66 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  339 ++++-
 drivers/net/wireless/ath/ath10k/debug.h            |   34 +-
 drivers/net/wireless/ath/ath10k/htc.c              |  115 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    7 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    9 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  171 ++-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   46 +-
 drivers/net/wireless/ath/ath10k/hw.h               |    5 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  717 +++++----
 drivers/net/wireless/ath/ath10k/mac.h              |    6 +-
 drivers/net/wireless/ath/ath10k/pci.c              | 1537 +++++++++-------=
----
 drivers/net/wireless/ath/ath10k/pci.h              |  104 +-
 drivers/net/wireless/ath/ath10k/spectral.c         |  561 +++++++
 drivers/net/wireless/ath/ath10k/spectral.h         |   90 ++
 drivers/net/wireless/ath/ath10k/txrx.c             |   17 +-
 drivers/net/wireless/ath/ath10k/wmi.c              | 1089 ++++++++++----
 drivers/net/wireless/ath/ath10k/wmi.h              |  699 +++++++--
 drivers/net/wireless/ath/ath5k/attach.c            |    3 +-
 drivers/net/wireless/ath/ath5k/base.c              |    2 +-
 drivers/net/wireless/ath/ath5k/debug.c             |   96 ++
 drivers/net/wireless/ath/ath5k/led.c               |    1 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    1 +
 drivers/net/wireless/ath/ath6kl/init.c             |    2 +-
 drivers/net/wireless/ath/ath6kl/main.c             |    2 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |    1 +
 drivers/net/wireless/ath/ath6kl/usb.c              |   21 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   48 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    9 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |  136 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   59 +-
 drivers/net/wireless/ath/ath9k/channel.c           | 1291 +++++++++++-----
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |   83 +-
 drivers/net/wireless/ath/ath9k/main.c              |  462 ++----
 drivers/net/wireless/ath/ath9k/recv.c              |   13 +-
 drivers/net/wireless/ath/ath9k/spectral.h          |   71 +-
 drivers/net/wireless/ath/ath9k/wow.c               |    3 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    7 +-
 drivers/net/wireless/ath/carl9170/main.c           |   11 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    2 +-
 drivers/net/wireless/ath/spectral_common.h         |  113 ++
 drivers/net/wireless/ath/wil6210/cfg80211.c        |    6 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |  331 ++++-
 drivers/net/wireless/ath/wil6210/interrupt.c       |    2 +-
 drivers/net/wireless/ath/wil6210/main.c            |   30 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    8 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    7 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   16 +
 drivers/net/wireless/ath/wil6210/txrx.c            |    3 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    2 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   17 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   49 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |    4 +-
 drivers/net/wireless/atmel_cs.c                    |   22 +-
 drivers/net/wireless/b43/Makefile                  |    1 +
 drivers/net/wireless/b43/b43.h                     |   18 +
 drivers/net/wireless/b43/bus.c                     |   10 +
 drivers/net/wireless/b43/bus.h                     |   15 +
 drivers/net/wireless/b43/main.c                    |   17 +-
 drivers/net/wireless/b43/phy_a.c                   |    4 +-
 drivers/net/wireless/b43/phy_common.c              |   25 +-
 drivers/net/wireless/b43/phy_g.c                   |    8 +-
 drivers/net/wireless/b43/phy_ht.c                  |   20 +-
 drivers/net/wireless/b43/phy_lcn.c                 |   20 +-
 drivers/net/wireless/b43/phy_lp.c                  |   20 +-
 drivers/net/wireless/b43/phy_n.c                   |  128 +-
 drivers/net/wireless/b43/phy_n.h                   |    4 +
 drivers/net/wireless/b43/ppr.c                     |  199 +++
 drivers/net/wireless/b43/ppr.h                     |   45 +
 drivers/net/wireless/b43/tables_nphy.c             |  128 +-
 drivers/net/wireless/b43/tables_nphy.h             |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    6 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   18 +-
 drivers/net/wireless/cw1200/cw1200_spi.c           |    4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    6 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   10 +
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    2 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |    7 -
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    2 +
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |    2 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    2 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    5 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    2 +
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    2 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    3 +
 drivers/net/wireless/iwlwifi/iwl-scd.h             |  118 ++
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   67 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |    2 +
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |    2 +
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    2 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |   10 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   76 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.h         |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   48 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    6 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |  106 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  104 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   41 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |    2 +
 drivers/net/wireless/iwlwifi/mvm/offloading.c      |    2 +
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   16 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    2 +
 drivers/net/wireless/iwlwifi/mvm/power.c           |  148 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   14 +
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   66 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   21 +
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   50 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |    2 +
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   94 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   22 +-
 drivers/net/wireless/iwlwifi/mvm/testmode.h        |    2 +
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   61 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    8 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   24 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   23 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    2 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    8 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    1 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    2 +
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  137 +-
 drivers/net/wireless/libertas/cfg.c                |    2 +
 drivers/net/wireless/mwifiex/cfg80211.c            |    3 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   29 +-
 drivers/net/wireless/mwifiex/fw.h                  |    9 +-
 drivers/net/wireless/mwifiex/init.c                |    4 +-
 drivers/net/wireless/mwifiex/main.h                |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |    3 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    4 +-
 drivers/net/wireless/mwifiex/util.c                |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |   10 +-
 drivers/net/wireless/orinoco/scan.c                |   14 +-
 drivers/net/wireless/ray_cs.h                      |    5 +-
 drivers/net/wireless/rayctl.h                      |    5 +-
 drivers/net/wireless/rndis_wlan.c                  |   14 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |    6 +
 drivers/net/wireless/ti/wl1251/spi.c               |    1 -
 drivers/net/wireless/ti/wlcore/spi.c               |   20 +-
 drivers/staging/rtl8723au/core/rtw_mlme_ext.c      |    2 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |    5 +-
 drivers/staging/wlan-ng/cfg80211.c                 |    1 +
 include/linux/bcma/bcma_regs.h                     |    5 +
 include/linux/ieee80211.h                          |   65 +
 include/net/bluetooth/hci_core.h                   |    8 +-
 include/net/bluetooth/l2cap.h                      |   33 +-
 include/net/cfg80211.h                             |   25 +-
 include/net/mac80211.h                             |   14 +-
 include/uapi/linux/nl80211.h                       |   16 +-
 net/bluetooth/6lowpan.c                            |   10 +-
 net/bluetooth/hci_core.c                           |   71 +-
 net/bluetooth/hci_event.c                          |   11 +-
 net/bluetooth/l2cap_core.c                         |  309 ++--
 net/bluetooth/l2cap_sock.c                         |   15 +-
 net/bluetooth/mgmt.c                               |  124 +-
 net/bluetooth/smp.c                                |  726 ++++++---
 net/bluetooth/smp.h                                |   10 +-
 net/ieee802154/6lowpan_rtnl.c                      |    8 -
 net/mac80211/cfg.c                                 |   13 +-
 net/mac80211/chan.c                                |  191 ++-
 net/mac80211/debugfs_sta.c                         |    3 +-
 net/mac80211/ibss.c                                |    2 +-
 net/mac80211/ieee80211_i.h                         |    1 -
 net/mac80211/key.c                                 |   12 +-
 net/mac80211/mesh_pathtbl.c                        |    4 +-
 net/mac80211/mesh_plink.c                          |   14 +-
 net/mac80211/mlme.c                                |   33 +-
 net/mac80211/rx.c                                  |    2 +-
 net/mac80211/scan.c                                |    2 +-
 net/mac80211/sta_info.c                            |    4 +-
 net/mac80211/sta_info.h                            |    2 -
 net/mac80211/tdls.c                                |    3 +-
 net/mac80211/tx.c                                  |   11 +-
 net/mac80211/wme.c                                 |    4 +-
 net/mac802154/rx.c                                 |    5 +-
 net/mac802154/tx.c                                 |   15 +-
 net/mac802154/wpan.c                               |   10 +-
 net/wireless/core.c                                |   13 +-
 net/wireless/mlme.c                                |    4 +-
 net/wireless/nl80211.c                             |   16 +-
 net/wireless/scan.c                                |   21 +-
 213 files changed, 8799 insertions(+), 4531 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/spectral.c
 create mode 100644 drivers/net/wireless/ath/ath10k/spectral.h
 create mode 100644 drivers/net/wireless/ath/spectral_common.h
 create mode 100644 drivers/net/wireless/b43/ppr.c
 create mode 100644 drivers/net/wireless/b43/ppr.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-scd.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUDgCOAAoJEJctW/TcYTgGuccQAJk2WX19L8GE+YbSnZ+AXsPt
NkjRKhzR4ZM9RBmntr6Npa2EO/7nKUS5qOZEtD73HP0/y9FJpDoYecYenbq9Up5J
LDRE3jpbwguY8GbjQ7WbO7cpJvjOK8io8+9IkN71TGSMhpWbtUEYW4DhGquxqbGK
I2uMj2ykE9qcGjMKVbsRmGzBvaGgXiRMYSU8bJVryFiFz9BBh6EjG5G7n9gs+7iF
0jXeQAmkLvz6WSYaf9dLfK76LuA1dN0Bia/l5N21tFQ9fmQvxik2unE5D6NbmBWq
FNUvvywISpO8GAqrGVVcCwEwEK3wEEpvRio6njxom6QLzKFydj3igro3Hw3i+g3g
7kKzT1K0MUZGySnnu6zFKBVrbzBLJoPbT+nP543kC1YEloxvFlciCAext9n9ky6B
Fvkph2qi0feDne1pWyM7L/ILC3LHCcEFYxSwhX/MKFOdrRebsI+KJpsZstGMu9NV
VMMaZMtL/IRUBoHas/swPKZd6nG5oa5mx10+tiomGaOjw3kRSoYVP88cwpJ/d1rX
8zUpB75kGRdBP2UqcJMHSKApUWQDMDMbmCeSvpYwebkHtuJn1MLYaJBKnzzxkTdK
WNJt8HvVUyr4DJcSXScZggnRlV+obXbfNPlmgQDof3w8gN5PB92tZXSTpK4EEFVC
OY9+Mcq7SkivfEpcYip5
=zT3Z
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
