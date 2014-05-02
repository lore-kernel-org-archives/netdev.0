From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-05-02
Date: Fri, 2 May 2014 14:18:02 -0400
Message-ID: <20140502181802.GQ3687@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qbvjkv9qwOGw/5Fx"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40272 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbaEBSaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 14:30:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qbvjkv9qwOGw/5Fx
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.16 stream...

For the mac80211 bits, Johannes says:

"In this round we have a large number of small features and
improvements from people too numerous to list here. The only really
bit thing is Micha=C5=82 and Luca's CSA work (including changing how
interface combination verification is done)."

For the Bluetooth bits, Gustavo says:

"Here goes some patches for the -next release. There is nothing
really special for this pull request, just a bunch of refactors,
fixes and clean ups."

For the ath10k/ath6kl bits, Kalle says:

"For ath6kl Kalle fixed a bunch of checkpatch warnings.

In ath10k we had more changes, major ones being:

* fix memory allocation failures after a firmware crash (Michal)

* some rework of DFS configuration to enable it correctly in all cases
  (Michal)

* add a new firmware crash option to make it possible to crash 10.1
  firmware for testing purposes (Marek P)

* fix RTS/CTS protection in certain cases (Marek K)

* fix wrong RSSI and rate reporting in some cases (Janusz)

* fix firmware stats reporting (Chun, Ben & Bartosz)"

For the iwlwifi bits, Emmanuel says:

"I have here a bunch of unrelated things. I disabled support for
-7.ucode which means that I can removed a lot of code. Eliad has
a brand new feature: we reduce the Tx power when the link allows -
this reduces our power consumption. The regular changes in power and
scan area. One interesting thing though is the patches from Johannes,
we have now GRO which allows to increase our throughput in TCP Rx. The
main advantage is that it reduces the number of TCP Acks - these TCP
Acks are completely useless when we are using A-MPDU since the first
packet of the A-MPDU generates a TCP Ack which is made obsolete by
the next packets."

Along with that, there are a variety of updates to b43, mwifiex,
rtl8180 and wil6210 drivers and a handful of other updates here
and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c25aaf814a63f9d9c4e45416f13d70ef0aa0be2e:

  hyperv: Enable sendbuf mechanism on the send path (2014-04-30 13:48:46 -0=
400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 406a94d7fae94a893c3afb9c2d18c83124d3cd9b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-05-02 13:47:50 -0400)

----------------------------------------------------------------

Adam Lee (2):
      Revert "rtlwifi: rtl8188ee: enable MSI interrupts mode"
      rtlwifi: rtl8723be: disable MSI interrupts mode

Amitkumar Karwar (12):
      mwifiex: increase SDIO multiport aggregation buffer sizes
      mwifiex: improve AMSDU packet aggregation for PCIe and SDIO
      mwifiex: increase the number of nodes in command pool
      mwifiex: use USB core's soft_unbind option
      mwifiex: remove redundant 'fw_load' completion structure
      mwifiex: fix IE parsing issues
      mwifiex: don't clear cmd_sent flag in timeout handler
      mwifiex: add fw_dump debugfs file
      mwifiex: add firmware dump feature for PCIe
      mwifiex: increase tx/rx AMPDU window sizes for STA 11n mode
      mwifiex: increase tx/rx AMPDU window sizes for STA 11ac mode
      mwifiex: enable aggregation for TID 6 and 7 streams

Andre Guedes (1):
      Bluetooth: Use memdup_user in le_auto_conn_write()

Andrea Merello (3):
      rtl8180: fix enabled interrupt mask for rtl8187se
      rtl8180: add parentheses to REG_ADDR macros
      rtl8180: be paranoid in stopping unused queues.

Arik Nemtsov (1):
      cfg80211: avoid freeing last_request while in flight

Avinash Patil (1):
      mwifiex: update timestamp information for aggregation packets

Avri Altman (2):
      iwlwifi: mvm: Handle power management constraints for additional use-=
cases
      iwlwifi: mvm: Re-factor enabling uAPSD logic

Bartosz Markowski (1):
      ath10k: update wal_dbg_tx_stats structure with missing parameter.

Ben Greear (4):
      ath10k: better firmware loading error messages
      ath10k: add otp and firmware boot error messages
      ath10k: fix getting stats from firmware
      ath10k: add the Rx rate in FW stats

Bing Zhao (2):
      Bluetooth: btmrvl: separate write-to-clear function from interrupt ha=
ndler
      Bluetooth: btmrvl: implement read-to-clear for SD8897 interrupts

Bob Copeland (3):
      mac80211: mesh: use u16 return type for u16 getter
      mac80211: fix mesh_add_rsn_ie IE finding loop
      mac80211: mesh: always use the latest target_sn

Christian Engelmayer (1):
      wlcore: fix usage of platform_device_add_data()

Chun-Yeow Yeoh (3):
      ath10k: allow the supported rate change by reassociate peer
      ath10k: fix the peer mac address in getting stats
      ath10k: add extra pdev stats on 10.1 firmware

David Spinadel (1):
      cfg80211: Add indoor only and GO concurrent channel attributes

Eliad Peller (4):
      iwlwifi: mvm: add lq_cmd/tx_resp reduced_tpc field
      iwlwifi: mvm: add ATPC implementation
      iwlwifi: mvm: add debugfs file for fixed reduced tx power
      iwlwifi: mvm: don't use d3 fw if d0i3 is used

Emmanuel Grumbach (28):
      iwlwifi: pcie: don't leave the new NICs awake for commands
      mac80211: add vif to flush call
      iwlwifi: pcie: unify iwl_rx_replenish and iwl_rx_replenish_now
      iwlwifi: mvm: remove redundant empty line
      iwlwifi: mvm: propagate the beamforming status from firmware
      iwlwifi: mvm: don't set AP STA to EINVAL
      iwlwifi: allow to wait for a subset of the queues
      iwlwifi: pcie: WARN upon traffic while flushing TX queues
      iwlwifi: mvm: dump Rx FIFO when the firmware asserts
      iwlwifi: mvm: don't enable bcast filtering on P2P client
      iwlwifi: mvm: replace BUG_ON by WARN_ON in scan.c
      iwlwifi: mvm: deprecate -7 firmware
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_NEWBT_COEX TLV flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_PM_CMD_SUPPORT flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_RX_ENERGY_API flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_TIME_EVENT_API_V2 flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_BF_UPDATED flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_D3_CONTINUITY_API flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_SCHED_SCAN flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_STA_KEY_CMD flag
      iwlwifi: remove IWL_UCODE_TLV_FLAGS_DEVICE_PS_CMD flag
      iwlwifi: mvm: BT Coex - don't use comma operator
      iwlwifi: mvm: BT Coex - minor API change
      iwlwifi: mvm: BT Coex - send priority tables from iwl_send_bt_init_co=
nf
      iwlwifi: 7000: bump firmware API version to 9
      iwlwifi: mvm: replace leading spaces by tabs
      iwlwifi: don't disable SCD chain extension on newer devices

Eran Harary (2):
      iwlwifi: mvm: fix the number of channels in family 8000
      iwlwifi: move CPU1_CPU2_SEPARATOR_SECTION to iwl-fw.h

Eyal Shapira (1):
      iwlwifi: mvm: add per rate tx stats

Eytan Lifshitz (2):
      iwlwifi: mvm: Fix warning message when exit thermal throttling
      iwlwifi: mvm: Fix tx-backoff when NIC exit thermal throttling

Felix Fietkau (2):
      ath9k: support only one P2P interface
      ath9k: implement p2p client powersave support

Haim Dreyfuss (1):
      iwlwifi: mvm: Add support for Energy based scan (EBS)

Ilan Peer (5):
      cfg80211: Add Kconfig option for cellular BS hints
      cfg80211: Enable GO operation on additional channels
      cfg80211: Add an option to hint indoor operation
      cfg80211: Enable GO operation on indoor channels
      cfg80211: Fix GO Concurrent relaxation on UNII-3

Jahnavi Meher (1):
      rsi: Changing opcode for sta mode according to changes in firmware

Jan-Simon M=C3=B6ller (1):
      mac80211: remove VLAIS usage from mac80211

Janusz Dziedzic (13):
      ath10k: add ath10k_htt_rx_amsdu_allowed function
      ath10k: Fill per-ppdu info in rx_info only once
      ath10k: move rx related functions to htt_rx.c
      ath10k: rename process_rx_rates to ath10k_htt_rx_h_rates
      ath10k: introduce ieee80211_rx_status to htt_rx_info
      ath10k: setup rx channel per ppdu
      ath10k: kill not needed fields from htt_rx_info
      ath10k: return error when ath10k_htt_rx_amsdu_pop() fail
      ath10k: improve way we play with attention flags
      ath10k: finally kill htt_rx_info
      ath10k: introduce rx_status htt template
      ath10k: fix rssi and rate reporting
      cfg80211: reg: set DFS CAC time in case of custom regd

Joe Perches (1):
      iwlegacy: Convert /n to \n

Johan Hedberg (15):
      Bluetooth: Refactor advertising report processing into its own functi=
on
      Bluetooth: Move local identity address setting to a central place
      Bluetooth: Fix LE responder/initiator address setting
      Bluetooth: Add error mapping for Directed Advertising Timeout
      Bluetooth: Don't send device found events during passive scanning
      Bluetooth: Add scan_rsp parameter to mgmt_device_found()
      Bluetooth: Add directed advertising support through connect()
      Bluetooth: Merge ADV_IND/ADV_SCAN_IND and SCAN_RSP together
      Bluetooth: Remove redundant NULL check
      Bluetooth: Fix line splitting of mgmt_device_found parameters
      Bluetooth: Don't send device found events for duplicate reports
      Bluetooth: Store also RSSI for pending advertising reports
      Bluetooth: Fix RSSI value in device found event from disabling scan
      Bluetooth: Remove unnecessary NULL check in hci_inquiry_cache_update
      Bluetooth: Fix address in unmergeable device found events

Johannes Berg (8):
      cfg80211: allow userspace to take ownership of interfaces
      cfg80211: reject invalid IBSS BSSIDs in wext compat code
      cfg80211: ignore invalid BSSIDs when looking for BSSes
      iwlwifi: pcie: implement GRO without NAPI
      iwlwifi: pcie: clarify RX queue need_update handling and locking
      iwlwifi: pcie: use bool for TX queue where appropriate
      iwlwifi: pcie: fix TX queue locking
      iwlwifi: pcie: clarify TX queue need_update handling

John W. Linville (6):
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Revert "mwifiex: add firmware dump feature for PCIe"
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (4):
      mac80211: Allow HT capa override to add 40 MHz intolerant
      cfg80211: Dynamic channel bandwidth changes in AP mode
      mac80211: Support dynamic AP mode channel width changes
      mac80211_hwsim: Advertise support for AP mode channel width changes

Julia Lawall (1):
      ray_cs: replace del_timer by del_timer_sync

Kalle Valo (19):
      ath6kl: fix struct hif_scatter_req list handling
      ath6kl: fix blank lines before and after braces
      ath6kl: use braces on both arms of if statement
      ath6kl: remove spaces before semicolon
      ath6kl: remove unnecessary line continuations
      ath6kl: update Kconfig descriptions
      ath10k: separate result parameter in ath10k_bmi_execute()
      ath10k: check otp.bin result
      ath10k: unify warning messages in mac.c
      ath10k: cleanup ath10k_pci_wait_for_target_init()
      ath10k: add module parameter to disable cold reset
      ath10k: fix name of target_ps module parameter
      ath10k: advertise only firmware API 2 files
      ath10k: delete ar_pci->fw_indicator_address
      ath10k: improve pci debug messages
      ath10k: add module parameter values to the pci info print
      ath10k: print chip id during boot
      ath10k: cleanup debug messages in ath10k_wmi_event_host_swba()
      cfg80211: update comment about WIPHY_FLAG_CUSTOM_REGULATORY

Larry Finger [ original patch ] (1):
      rtl8180: change module name in rtl818x_pci

Luciano Coelho (9):
      cfg80211: refactor cfg80211_can_use_iftype_chan()
      cfg80211/mac80211: refactor cfg80211_chandef_dfs_required()
      cfg80211/mac80211: move interface counting for combination check to m=
ac80211
      cfg80211/mac80211: move combination check to mac80211 for ibss
      cfg80211/mac80211: move more combination checks to mac80211
      mac80211: split ieee80211_vif_change_channel in two
      mac80211: refactor ieee80211_assign/unassign_vif_chanctx into one
      mac80211: implement chanctx reservation
      mac80211: allow reservation of a running chanctx

Luis R. Rodriguez (1):
      cfg80211: fix processing world regdomain when non modular

Lukasz Rymanowski (3):
      Bluetooth: Keep msec in DISCOV_INTERLEAVED_TIMEOUT
      Bluetooth: Add new debugfs parameter
      Bluetooth: Keep msec in DISCOV_LE_TIMEOUT

Maithili Hinge (1):
      mwifiex: change memset to simple assignment for ht_cap.mcs.rx_mask

Marcel Holtmann (1):
      Bluetooth: Return EOPNOTSUPP for HCISETRAW ioctl command

Marek Kwaczynski (2):
      ath10k: add recalc RTS/CTS protection method
      mac80211: add option to generate CCMP IVs only for mgmt frames

Marek Puzyniak (2):
      ath10k: add soft/hard firmware crash option to simulate_fw_crash
      ath10k: update regulatory domain settings for 10.x firmware

Michal Kazior (21):
      ath10k: convert pci_alloc_consistent() to dma_alloc_coherent()
      ath10k: split ce initialization and allocation
      ath10k: deinit copy engine before resetting
      ath10k: refactor monitor code
      mac80211: protect AP VLAN list with local->mtx
      cfg80211: fix radar_detect combination checking
      ath10k: reorder functions
      ath10k: refactor radar detection code
      ath10k: improve htc tx credit debugging prints
      cfg80211: allow drivers to iterate over matching combinations
      mac80211: add max channel calculation utility function
      mac80211: prevent chanctx overcommit
      mac80211: add support for radar detection for reservations
      mac80211: track assigned vifs in chanctx
      mac80211: track reserved vifs in chanctx
      mac80211: improve find_chanctx() for reservations
      mac80211: improve chanctx reservation lookup
      mac80211: split ieee80211_new_chanctx()
      mac80211: split ieee80211_free_chanctx()
      mac80211: fix racy usage of chanctx->refcount
      mac80211: compute chanctx refcount on-the-fly

Mikel Astiz (3):
      Bluetooth: Refactor hci_get_auth_req()
      Bluetooth: Refactor code for outgoing dedicated bonding
      Bluetooth: Request MITM Protection when initiator

Monam Agarwal (3):
      cfg80211: regulatory: use RCU_INIT_POINTER
      mac80211: use RCU_INIT_POINTER
      iwlwifi: mvm: Use RCU_INIT_POINTER(x, NULL)

Nickolay Ledovskikh (1):
      ath5k: Fix AR5K_PHY_TXPOWER_RATE_MAX register value setting.

Pawel Kulakowski (1):
      mac80211: Allow disabling LDPC

Petri Gynther (1):
      Bluetooth: btmrvl: Fix btmrvl_send_module_cfg_cmd()

Poulain, Loic (1):
      Bluetooth: Remove hci_h4 unused defines

Rafa=C5=82 Mi=C5=82ecki (16):
      b43: G-PHY: fix random mistakes to match specs
      b43: N-PHY: drop second noise variance table
      b43: N-PHY: rev3+: complete workarounds
      b43: N-PHY: random updates and typo fixes all around
      b43: N-PHY: implement reading support for radio 0x2057
      b43: N-PHY: implement RF control INTC for revs 7+
      b43: N-PHY: prepare for rev 7+ RSSI calibration
      b43: N-PHY: add init & calib values for radio 0x2056 rev 11
      b43: N-PHY: fix selection of init & calib values
      b43: N-PHY: enable forgotten write of hw power adjust table
      b43: ssb: refuse to support more than IEEE 802.11 core
      b43: remove list of IEEE 802.11 devices
      b43: bcma: respect GMODE (band choice) during core reset
      b43: use b43_software_rfkill helper
      b43: don't pre-set radio_on variable to true
      b43: N-PHY: complete radio 0x2056 setup

Rajkumar Manoharan (2):
      ath9k_hw: update ar9300 initvals
      ath9k_hw: fix worse EVM for 11b rates

Rostislav Lisovy (3):
      mac80211: Update conf_is_ht() to work properly with 5/10MHz channels
      cfg80211: Add attributes describing prohibited channel bandwidth
      cfg80211: Use 5MHz bandwidth by default when checking usable channels

Stanislaw Gruszka (1):
      rt2x00: restore original beaconing state

Timo Mueller (1):
      Bluetooth: Use MITM Protection when IO caps allow it

Vladimir Kondratiev (4):
      wil6210: fix printouts for better readability
      wil6210: sync with the latest FW API
      wil6210: relaxed check for BACK start sequence
      wil6210: Use larger Tx rings

Zhao, Gang (11):
      cfg80211: slightly clean up of cfg80211_sme_connect()
      mac80211: fix some missing includes
      cfg80211: remove unused wiphy argument from cfg80211_wext_freq()
      mac80211: return bool instead of numbers in yes/no function
      mac80211: remove unnecessary BUG_ON()
      cfg80211: change registered device pointer name
      cfg80211: change wiphy_to_dev function name
      cfg80211: change return value of notifier function
      mac80211: change return value of notifier function
      mac80211: avoid calling useless channel context code
      mac80211: remove unnecessary assignment

 Documentation/DocBook/80211.tmpl                   |   1 +
 drivers/bluetooth/btmrvl_drv.h                     |   4 +-
 drivers/bluetooth/btmrvl_main.c                    |  19 +-
 drivers/bluetooth/btmrvl_sdio.c                    | 103 ++-
 drivers/bluetooth/btmrvl_sdio.h                    |   3 +
 drivers/bluetooth/hci_h4.c                         |   7 -
 drivers/net/wireless/ath/ar5523/ar5523.c           |   3 +-
 drivers/net/wireless/ath/ath10k/bmi.c              |  13 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |   2 +-
 drivers/net/wireless/ath/ath10k/ce.c               | 356 +++++-----
 drivers/net/wireless/ath/ath10k/ce.h               |  15 +-
 drivers/net/wireless/ath/ath10k/core.c             |  85 ++-
 drivers/net/wireless/ath/ath10k/core.h             |  18 +-
 drivers/net/wireless/ath/ath10k/debug.c            | 109 ++-
 drivers/net/wireless/ath/ath10k/htc.c              |  12 +-
 drivers/net/wireless/ath/ath10k/htt.h              |  21 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           | 513 +++++++++-----
 drivers/net/wireless/ath/ath10k/hw.h               |   1 +
 drivers/net/wireless/ath/ath10k/mac.c              | 766 ++++++++++++-----=
----
 drivers/net/wireless/ath/ath10k/pci.c              | 219 ++++--
 drivers/net/wireless/ath/ath10k/pci.h              |   3 -
 drivers/net/wireless/ath/ath10k/txrx.c             | 183 -----
 drivers/net/wireless/ath/ath10k/txrx.h             |   1 -
 drivers/net/wireless/ath/ath10k/wmi.c              |  62 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |  98 ++-
 drivers/net/wireless/ath/ath5k/phy.c               |   4 +-
 drivers/net/wireless/ath/ath6kl/Kconfig            |  30 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   9 +-
 drivers/net/wireless/ath/ath6kl/core.c             |   6 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   4 -
 drivers/net/wireless/ath/ath6kl/debug.h            |   2 +-
 drivers/net/wireless/ath/ath6kl/hif.c              |   3 -
 drivers/net/wireless/ath/ath6kl/hif.h              |   4 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |  23 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |  10 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   1 -
 drivers/net/wireless/ath/ath6kl/main.c             |  10 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |  17 +-
 drivers/net/wireless/ath/ath6kl/target.h           |   2 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |  31 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   2 -
 drivers/net/wireless/ath/ath6kl/wmi.c              |  19 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |   1 -
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |   2 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |   2 +-
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   |   2 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |   8 +-
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |   6 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |   2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  12 +
 drivers/net/wireless/ath/ath9k/init.c              |  10 +-
 drivers/net/wireless/ath/ath9k/main.c              | 109 ++-
 drivers/net/wireless/ath/ath9k/recv.c              |   3 +
 drivers/net/wireless/ath/carl9170/main.c           |   4 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   2 +-
 drivers/net/wireless/ath/wil6210/main.c            |   4 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   2 -
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |  17 +
 drivers/net/wireless/ath/wil6210/wil6210.h         |   3 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  11 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |  50 +-
 drivers/net/wireless/b43/b43.h                     |   4 -
 drivers/net/wireless/b43/main.c                    |  97 ++-
 drivers/net/wireless/b43/phy_common.c              |   6 +-
 drivers/net/wireless/b43/phy_g.c                   |   6 +-
 drivers/net/wireless/b43/phy_n.c                   | 304 ++++++--
 drivers/net/wireless/b43/radio_2056.c              | 418 +++++++++--
 drivers/net/wireless/b43/tables_nphy.c             |  72 +-
 drivers/net/wireless/b43/tables_nphy.h             |   3 +-
 drivers/net/wireless/b43/wa.c                      |   2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   3 +-
 drivers/net/wireless/cw1200/sta.c                  |   3 +-
 drivers/net/wireless/cw1200/sta.h                  |   3 +-
 drivers/net/wireless/iwlegacy/3945.c               |   2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   2 +-
 drivers/net/wireless/iwlegacy/common.c             |   3 +-
 drivers/net/wireless/iwlegacy/common.h             |   3 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   5 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |  12 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   1 +
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   1 +
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   3 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   9 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   5 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |  27 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  25 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |  25 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   8 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  10 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  34 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  94 ++-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |  13 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  15 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |  38 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |  17 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |   2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  26 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |  46 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |   3 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  54 +-
 drivers/net/wireless/iwlwifi/mvm/fw-error-dump.h   |   6 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  12 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   5 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  49 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  26 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  56 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           | 272 ++++----
 drivers/net/wireless/iwlwifi/mvm/rs.c              | 330 ++++++++-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |  24 +
 drivers/net/wireless/iwlwifi/mvm/rx.c              |  45 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  20 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |   3 -
 drivers/net/wireless/iwlwifi/mvm/sta.c             | 177 +----
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   3 +
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |  71 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |  10 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |  11 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |  46 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   9 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  84 +--
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  47 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  62 +-
 drivers/net/wireless/mac80211_hwsim.c              |   5 +-
 drivers/net/wireless/mwifiex/11ac.c                |   3 +-
 drivers/net/wireless/mwifiex/11n.c                 |   3 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |  21 +-
 drivers/net/wireless/mwifiex/README                |   7 +
 drivers/net/wireless/mwifiex/cmdevt.c              |   2 -
 drivers/net/wireless/mwifiex/debugfs.c             |  25 +
 drivers/net/wireless/mwifiex/decl.h                |   8 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   2 +-
 drivers/net/wireless/mwifiex/main.c                |   2 -
 drivers/net/wireless/mwifiex/main.h                |   2 +-
 drivers/net/wireless/mwifiex/pcie.c                |   3 -
 drivers/net/wireless/mwifiex/scan.c                |  37 +-
 drivers/net/wireless/mwifiex/sdio.c                |   9 +-
 drivers/net/wireless/mwifiex/sdio.h                |  18 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   8 +-
 drivers/net/wireless/mwifiex/usb.c                 |  55 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   9 -
 drivers/net/wireless/p54/main.c                    |   3 +-
 drivers/net/wireless/ray_cs.c                      |   2 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |   4 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                |   1 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |  15 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   3 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  10 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  10 +-
 drivers/net/wireless/rtl818x/rtl8180/Makefile      |   4 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |  10 +-
 drivers/net/wireless/rtl818x/rtl818x.h             |   6 +-
 drivers/net/wireless/rtlwifi/core.c                |   3 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   1 -
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   3 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |  28 +-
 drivers/net/wireless/ti/wlcore/spi.c               |  23 +-
 drivers/staging/rtl8821ae/core.c                   |  14 +-
 include/net/bluetooth/hci.h                        |   1 +
 include/net/bluetooth/hci_core.h                   |  13 +-
 include/net/cfg80211.h                             |  86 ++-
 include/net/mac80211.h                             |  31 +-
 include/net/regulatory.h                           |   6 +
 include/uapi/linux/nl80211.h                       |  42 ++
 net/bluetooth/hci_conn.c                           |  81 ++-
 net/bluetooth/hci_core.c                           |  20 +-
 net/bluetooth/hci_event.c                          | 246 +++++--
 net/bluetooth/hci_sock.c                           |  11 +-
 net/bluetooth/lib.c                                |   1 +
 net/bluetooth/mgmt.c                               |  36 +-
 net/mac80211/aes_ccm.c                             |  37 +-
 net/mac80211/cfg.c                                 |  53 +-
 net/mac80211/chan.c                                | 614 ++++++++++++++---
 net/mac80211/debugfs.c                             |   2 +-
 net/mac80211/debugfs.h                             |   2 +
 net/mac80211/debugfs_netdev.h                      |   2 +
 net/mac80211/driver-ops.h                          |   8 +-
 net/mac80211/ht.c                                  |  22 +-
 net/mac80211/ibss.c                                |  75 +-
 net/mac80211/ieee80211_i.h                         |  33 +-
 net/mac80211/iface.c                               |  36 +-
 net/mac80211/main.c                                |   8 +-
 net/mac80211/mesh.c                                |  36 +-
 net/mac80211/mesh_hwmp.c                           |   5 +-
 net/mac80211/michael.h                             |   1 +
 net/mac80211/mlme.c                                |   4 +-
 net/mac80211/rx.c                                  |  19 +-
 net/mac80211/scan.c                                |  10 +-
 net/mac80211/sta_info.c                            |   3 +-
 net/mac80211/util.c                                | 145 +++-
 net/mac80211/wpa.c                                 |   5 +-
 net/wireless/Kconfig                               |  37 +
 net/wireless/chan.c                                | 176 ++++-
 net/wireless/core.c                                |  75 +-
 net/wireless/core.h                                |  46 +-
 net/wireless/ethtool.c                             |  10 +-
 net/wireless/ibss.c                                |  41 +-
 net/wireless/mesh.c                                |  28 +-
 net/wireless/mlme.c                                |  38 +-
 net/wireless/nl80211.c                             | 499 +++++++-------
 net/wireless/rdev-ops.h                            |  13 +
 net/wireless/reg.c                                 | 153 +++-
 net/wireless/reg.h                                 |  18 +
 net/wireless/scan.c                                | 154 +++--
 net/wireless/sme.c                                 |  40 +-
 net/wireless/trace.h                               |  29 +-
 net/wireless/util.c                                | 171 +++--
 net/wireless/wext-compat.c                         |  40 +-
 net/wireless/wext-compat.h                         |   2 +-
 net/wireless/wext-sme.c                            |  12 +-
 213 files changed, 6045 insertions(+), 3415 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Qbvjkv9qwOGw/5Fx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTY+FaAAoJEJctW/TcYTgGl8QP/1Pxm+b+x2d3RP8n9qWtRtA8
rNf6wQ8qeExD3NZxryP/Qwlrza7tFRMFeO8Kc4R18Sc5k67rlBeGmTRRBfcF65Qf
5SI7Oo4K50QJaquu1y9jNkpP/vk0wwlpAaNduOCaodWepXzNFDxA0Ko0Os7oK/+X
D/TKdtyptIpnVvjy4AhJko43IbpO+iUnfyDwijziOkRrh6F2T2mJJVHVVqC048rV
TLBcYlVHQWAUQoVlSBl+A7UxwqWxqZRzrwjym3n8q5VC+EaLcSBjGvPXmUPGwQjF
gsIJO5Y4czcLTHVRh7SPRlRKnWMIe0nLsKkUvizPAua9Nz0XEmYKJs/VgjDyOLlL
TckUYOKD4Et6JtS+rzlr5dEfGE2dJf0bIBDwRhDca4wsYLMIIFzM8p+NptxvHqUq
6TSuXHp3U84YkPygK/8Cp1GUXjV3L1Ldgw1J5z5FyTguoQwTbVyWITKvUBbHISFl
UNUSVtUFkBk/us71gKSyV7ou7ETelv9Cb/Pym7acwo1St7lWoa/H+VmsPXIIIL2S
JLBip6Vhkz1jv+WbpXV3OPeu03J9gLFZhLYnsm1/Y89cNIoweBZEfNPo1lGP2+tR
FdJExEgvq58xkJOoKGTUKEvXpTnSCqH0+GRgYqWMsV7T1y/Y7Sc5ALfZgRY3OQdC
Wc3dEcXcaWwnrEPhJ1AW
=deY1
-----END PGP SIGNATURE-----

--Qbvjkv9qwOGw/5Fx--
