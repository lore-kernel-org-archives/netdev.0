From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-07-20
Date: Fri, 20 Jul 2012 13:20:15 -0400
Message-ID: <20120720172014.GB23254@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52974 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab2GTRdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 13:33:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 90b90f60c4f8e3a8525dfeb4aec46a9c7a29c857

Dave,

Here is what I hope to be the last non-fix pull request for wireless
bits going into 3.6.  It's mostly normal stuff, including driver
updates to ath9k, mwifiex, libertas, iwlwifi, and a few other bits.

Also included is a bluetooth pull.  Gustavo says:

	"This is my last pull towards 3.6, the biggest thing here is
	the new 3-wire UART Bluetooth driver by Johan Hedberg. The
	rest is just fixes and clean ups."

Finally, there is a pull of the wireless tree to pick-up a few minor
fixes I had queued that were not really worthy for this late in the
3.5 cycle.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 769162e38b91e1d300752e666260fa6c7b203fbc:

  Merge branch 'net' of git://git.kernel.org/pub/scm/linux/kernel/git/cmetc=
alf/linux-tile (2012-07-19 13:39:27 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 90b90f60c4f8e3a8525dfeb4aec46a9c7a29c857:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-07-20 12:30:48 -0400)

----------------------------------------------------------------

Alan Cox (1):
      mac80211: fix use after free

Amitkumar Karwar (5):
      mwifiex: correction in mcs index check
      mwifiex: remove redundant code in set channel path
      mwifiex: remove unnecessary code in data rate configuration
      mwifiex: add support to use basic rates in ibss join request
      mwifiex: improvement in cfg80211 set_bitrate_mask handler

Andre Guedes (4):
      Bluetooth: Remove magic value in disconnect mgmt handler
      Bluetooth: Use GFP_KERNEL in mgmt_handlers
      Bluetooth: Use GFP_KERNEL in mgmt_pending_add
      Bluetooth: Use GFP_KERNEL in mgmt events functions

Andrei Emeltchenko (20):
      Bluetooth: Use standard HCI cmd timeout for RESET
      Bluetooth: Update HCI timeouts constants to use msecs_to_jiffies
      Bluetooth: Add opcode to error message
      Bluetooth: Correct debug print specifier for u16 objects
      Bluetooth: Fix not setting HCI_RESET flag for AMP
      Bluetooth: Fix compile warnings in mgmt
      Bluetooth: Use AUTO_OFF constant in jiffies
      Bluetooth: Improve debugging messages for hci_conn
      Bluetooth: Fix warning: using int as NULL pointer
      Bluetooth: Route traffic only through BR/EDR controller
      Bluetooth: bluecard_cs: Shorten scope for iobase
      Bluetooth: Do not auto off AMP controller
      Bluetooth: btmrvl: trivial style fixes
      Bluetooth: debug: Add printing num of cmds queued
      Bluetooth: debug: Correct types specifiers for L2CAP
      Bluetooth: debug: Print CID and PSM in hex format
      Bluetooth: debug: Add debug to l2cap_security_cfm
      Bluetooth: debug: Use standard hex object specifiers in hci_event
      Bluetooth: debug: Print l2cap_chan refcount
      Bluetooth: debug: Print amp_mgr refcnt

Andy Shevchenko (1):
      wireless: brcm80211: use %pM to print BSSID

Arik Nemtsov (5):
      mac80211: fix invalid band deref building preq IEs
      wl18xx: alloc conf.phy memory to ensure alignemnt
      wl18xx: fix bogus compile warning on cc config option
      wlcore: don't issue SLEEP_AUTH command during recovery
      wl18xx: enable MIMO rates when connected as a MIMO STA

Christian Lamparter (2):
      mac80211: request TX status for BlockAck Requests
      mac80211: fix read outside array bounds

Chun-Yeow Yeoh (1):
      mac80211: Fix the Problem of Unreachable Mesh STA from DS

Daniel Drake (3):
      libertas: Update 11d info only when interface is active
      libertas: handle command failure immediately
      libertas USB: don't set surpriseremoved flag

Dave Jones (1):
      NFC: NCI module license 'unspecified' taints kernel

Devendra Naga (1):
      Bluetooth: cleanup dtl1_config

Duan Jiong (1):
      libertas: firmware.c: remove duplicated include

Eliad Peller (3):
      mac80211: go out of PS before sending disassoc
      wlcore: use basic rates for non-data packets
      mac80211: flush stations before stop beaconing

Emmanuel Grumbach (1):
      iwlwifi: REPLY_RX doesn't exist any more

Eric Lapuyade (1):
      NFC: Set target nfcid1 for all HCI reader A targets

Eyal Shapira (1):
      wlcore: don't re-configure wakeup conditions if not needed

Felix Fietkau (15):
      cfg80211: ignore channel state for stopped AP/mesh interfaces
      ath9k_hw: fix 5 GHz frequency selection on AR934x/AR955x with 25 MHz =
refclock
      ath9k_hw: fall back to OTP ROM when platform data has no valid eeprom=
 data
      ath9k: validate rx antenna settings
      ath9k_hw: enable ANI on AR934x
      ath9k_hw: fix tx gain tables for AR934x
      ath9k_hw: remove redundant arguments to INIT_INI_ARRAY
      ath9k/ath9k_htc: fix txop limit handling
      ath9k: make per-WMM-AC queue sizes configurable via debugfs
      ath9k: fix aggregate size limit based on queue TXOP limit
      ath9k_hw: apply XPA timing control values from EEPROM
      ath9k_hw: clean up AR9003 EEPROM code
      ath9k_hw: apply XLNA bias settings from EEPROM
      ath9k_hw: fix SREV checks for applying tuning caps from EEPROM
      ath5k: fix txop limit handling

Forest Bond (1):
      rtlwifi: rtl8192de: Fix phy-based version calculation

Gustavo Padovan (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth

Igal Chernobelsky (1):
      wlcore: send EAPOLs using minimum basic rate for all roles

Jaganath Kanakkassery (1):
      Bluetooth: Refactor PIN code rejection to use user_pairing_resp()

Jefferson Delfes (1):
      Bluetooth: Fix flags of mgmt_device_found event

Johan Hedberg (19):
      Bluetooth: Change page scan interval in fast connectable mode
      Bluetooth: Initial skeleton for Three-wire UART (H5) support
      Bluetooth: Add basic state tracking to Three-wire UART driver
      Bluetooth: Add initial reliable packet support for Three-wire UART
      Bluetooth: Add basic packet parsing to Three-wire UART driver
      Bluetooth: Add initial packet sending support to Three-wire UART
      Bluetooth: Add Three-wire header value convenience macros
      Bluetooth: Fix/implement Three-wire reliable packet sending
      Bluetooth: Add support for Three-wire Link Control packets
      Bluetooth: Simplify hci_uart_tty_close logic
      Bluetooth: Add delayed init sequence support for UART controllers
      Bluetooth: Use delayed init for Three-wire UART
      Bluetooth: Improve rx debug logs for Three-wire UART
      Bluetooth: Add initial sleep support to Three-wire UART
      Bluetooth: Add initialization tracking to HCI Three-wire driver
      Bluetooth: Implement proper low-power support for Three-wire UART
      Bluetooth: Remove unnecessary h5_build_pkt function
      Bluetooth: Improve Three-wire UART configuration handling
      Bluetooth: Introduce a flags variable to Three-wire UART state

Johannes Berg (27):
      mac80211: update BSS info on AC parameters change
      mac80211: remove unused assignment
      mac80211: remove ieee80211_key_removed
      nl80211: prepare for non-netdev wireless devs
      nl80211: add NL80211_FLAG_NEED_WDEV
      nl80211: retrieve interface data by wdev
      nl80211: don't assume wdev->netdev exists
      cfg80211: use wdev in mgmt-tx/ROC APIs
      cfg80211: use wireless_dev for interface management
      nl80211: send interface after creation
      nl80211: move scan API to wdev
      mac80211: make scan_sdata pointer usable with RCU
      mac80211: track scheduled scan virtual interface
      mac80211: redesign scan RX
      mac80211: optimize ieee80211_rx_status struct layout
      mac80211: add time synchronisation with BSS for assoc
      mac80211: restructure key selection
      cfg80211: fix locking and lockdep complaints
      mac80211: iterate the virtual monitor interface
      iwlwifi: don't use stack memory for kmem cache name
      nl80211: allow enabling WoWLAN without triggers
      Revert "mac80211: refactor virtual monitor code"
      cfg80211/mac80211: re-add get_channel operation
      cfg80211: reduce monitor interface tracking
      nl80211: add wdev ID as u64 as it should
      b43: use temporary rate_index for error checking
      b43: fix crash with OpenFWWF

John W. Linville (7):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth=
-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (1):
      cfg80211: fix set_regdom() to cancel requests with same alpha2

Larry Finger (2):
      rtlwifi: Remove extra argument from queue setup routine
      rtlwifi: rtl8192cu: Change buffer allocation for synchronous reads

Luciano Coelho (2):
      wlcore: wait for command completion event when sending CMD_ROLE_STOP
      wlcore: increase command completion timeout

Luis R. Rodriguez (6):
      cfg80211: add CONFIG_CFG80211_CERTIFICATION_ONUS
      cfg80211: add cellular base station regulatory hint support
      cfg80211: rename reg_device_remove() to wiphy_regulatory_deregister()
      cfg80211: make regulatory_update() static
      cfg80211: remove regulatory_update()
      ath9k: make CONFIG_ATH9K_DFS_CERTIFIED depend on CFG80211_CERTIFICATI=
ON_ONUS

Mat Martineau (1):
      Bluetooth: Use tx window from config response for ack timing

Mathias Jeppsson (2):
      NFC: Fix empty HCI message list check
      NFC: Fix order of arguments to list_add_tail() when queueing HCP fram=
es

Mohammed Shafi Shajakhan (11):
      ath9k_hw: Add register definitions for WoW support
      ath9k: Add definitions and structures to support WoW
      ath9k_hw: Add WoW hardware capability flags
      ath9k_hw: advertise WoW support for capable chipsets
      ath9k: advertise supported WoW flags to upper layer
      ath9k_hw: INI changes for WoW for AR9002 chipsets
      ath9k_hw: Add hardware code for WoW
      ath: Add Wake-on-Wireless debug mask
      ath9k: Add WoW related mac80211 callbacks
      ath9k: do not disable hardware while wow is enabled
      cfg80211: Fix mutex locking in reg_last_request_cell_base

Nicolas Cavallari (2):
      mac80211: tx: do not drop non-robust mgmt to non-MFP stas.
      mac80211: fix tx-mgmt cookie value being left uninitialized

Rafa=C5=82 Mi=C5=82ecki (6):
      bcma: support alternative (BCM4706) ChipCommon core id
      bcma: fix typo - reading number of slave wrappers
      bcma: add trivial GBIT MAC COMMON driver
      bcma: add new cores at the end of list
      bcma: cc: update defines
      bcma: add place for flash memory support

Rajkumar Manoharan (1):
      ath9k: Fix race in reset-work usage

Sujith Manoharan (11):
      ath9k: Fix beacon setup
      ath9k_hw: Cleanup ath9k_hw_set_tsfadjust
      ath9k: Cleanup interface handling
      ath9k: Simplify ASSOC handling
      ath9k: Cleanup beacon logic
      ath9k: Remove is_bslot_active
      ath9k: Cleanup beacon queue configuration
      ath9k: Set the TSF adjust value properly
      ath9k: Cleanup the beacon tasklet
      ath9k: Fix ANI management
      ath9k: Reconfigure VIF state properly

Sylvain Roger Rieunier (1):
      minstrel_ht: enable frame aggregation for fixed rate

Thomas Huehn (3):
      mwl8k: fix possible race condition in info->control.sta use
      brcmsmac: restructure info->control.sta handling as it is goning to b=
e removed soon.
      mac80211_hwsim: fix race condition with sta/vif pointers

Thomas Pedersen (1):
      cfg80211: support TX error rate CQM

Vladimir Kondratiev (1):
      cfg80211: fix oops due to unassigned set_monitor_enabled callback

Wey-Yi Guy (1):
      iwlwifi: set correct 32 bit boost register value

Yair Shapira (5):
      wl18xx: add support for ht_mode in conf.h
      wlcore: add plt_mode including new PLT_FEM_DETECT
      wl18xx: disable calibrator based fem detect
      wlcore/wl12xx: calibrator fem detect implementation
      wlcore: make usage of nla_put clearer

 Documentation/DocBook/80211.tmpl                   |    1 -
 drivers/bcma/Kconfig                               |   19 +
 drivers/bcma/Makefile                              |    3 +
 drivers/bcma/bcma_private.h                        |   22 +
 drivers/bcma/driver_chipcommon_nflash.c            |   19 +
 drivers/bcma/driver_chipcommon_sflash.c            |   19 +
 drivers/bcma/driver_gmac_cmn.c                     |   14 +
 drivers/bcma/driver_mips.c                         |   15 +-
 drivers/bcma/main.c                                |   25 +-
 drivers/bcma/scan.c                                |   20 +-
 drivers/bcma/scan.h                                |    2 +-
 drivers/bluetooth/Kconfig                          |   12 +
 drivers/bluetooth/Makefile                         |    1 +
 drivers/bluetooth/bluecard_cs.c                    |    6 +-
 drivers/bluetooth/bt3c_cs.c                        |    2 +-
 drivers/bluetooth/btmrvl_main.c                    |    8 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    3 +-
 drivers/bluetooth/btuart_cs.c                      |    2 +-
 drivers/bluetooth/dtl1_cs.c                        |   18 +-
 drivers/bluetooth/hci_h5.c                         |  747 ++++++++++++++++=
++++
 drivers/bluetooth/hci_ldisc.c                      |   66 +-
 drivers/bluetooth/hci_uart.h                       |   10 +
 drivers/net/wireless/ath/ath.h                     |    2 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   58 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    6 +-
 drivers/net/wireless/ath/ath6kl/core.c             |    8 +-
 drivers/net/wireless/ath/ath6kl/core.h             |    5 +
 drivers/net/wireless/ath/ath6kl/wmi.c              |   10 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    2 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    1 +
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  160 ++---
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |   14 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  198 +++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  546 ++++----------
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    5 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |   40 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |  523 ++++++--------
 drivers/net/wireless/ath/ath9k/calib.h             |    6 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   13 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   24 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    4 -
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   16 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   84 ++-
 drivers/net/wireless/ath/ath9k/init.c              |   21 +-
 drivers/net/wireless/ath/ath9k/link.c              |   73 +-
 drivers/net/wireless/ath/ath9k/main.c              |  691 +++++++++++++---=
--
 drivers/net/wireless/ath/ath9k/mci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    3 +
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  145 +++-
 drivers/net/wireless/ath/ath9k/wow.c               |  532 ++++++++++++++
 drivers/net/wireless/ath/ath9k/xmit.c              |  102 +--
 drivers/net/wireless/b43/b43.h                     |    7 -
 drivers/net/wireless/b43/main.c                    |   32 +-
 drivers/net/wireless/b43/xmit.c                    |    9 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    7 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |   11 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 +-
 drivers/net/wireless/iwlegacy/common.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    1 +
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    2 +
 drivers/net/wireless/iwlwifi/dvm/main.c            |    1 -
 drivers/net/wireless/iwlwifi/dvm/rx.c              |   44 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    1 +
 drivers/net/wireless/iwlwifi/pcie/2000.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    7 +-
 drivers/net/wireless/libertas/cfg.c                |    7 +-
 drivers/net/wireless/libertas/cmd.c                |   25 +-
 drivers/net/wireless/libertas/cmd.h                |    4 +-
 drivers/net/wireless/libertas/dev.h                |    1 +
 drivers/net/wireless/libertas/firmware.c           |    2 -
 drivers/net/wireless/libertas/if_usb.c             |    1 -
 drivers/net/wireless/libertas/main.c               |    6 +
 drivers/net/wireless/mac80211_hwsim.c              |    5 -
 drivers/net/wireless/mwifiex/cfg80211.c            |  287 ++++----
 drivers/net/wireless/mwifiex/cfp.c                 |   31 -
 drivers/net/wireless/mwifiex/decl.h                |    9 -
 drivers/net/wireless/mwifiex/fw.h                  |   10 -
 drivers/net/wireless/mwifiex/init.c                |    1 -
 drivers/net/wireless/mwifiex/ioctl.h               |    6 -
 drivers/net/wireless/mwifiex/main.c                |    4 +-
 drivers/net/wireless/mwifiex/main.h                |   20 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   38 -
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   70 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  287 +-------
 drivers/net/wireless/mwl8k.c                       |    5 +-
 drivers/net/wireless/orinoco/cfg.c                 |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    5 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    2 +-
 drivers/net/wireless/rtlwifi/base.h                |    2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    6 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   14 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    1 +
 drivers/net/wireless/ti/wl12xx/cmd.c               |   34 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   23 +
 drivers/net/wireless/ti/wl18xx/conf.h              |   21 +-
 drivers/net/wireless/ti/wl18xx/io.c                |    2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  117 ++-
 drivers/net/wireless/ti/wlcore/cmd.c               |   12 +
 drivers/net/wireless/ti/wlcore/cmd.h               |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   44 +-
 drivers/net/wireless/ti/wlcore/testmode.c          |   85 ++-
 drivers/net/wireless/ti/wlcore/tx.c                |   14 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    2 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    8 +-
 include/linux/bcma/bcma.h                          |    2 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   51 +-
 include/linux/bcma/bcma_driver_gmac_cmn.h          |  100 +++
 include/linux/nl80211.h                            |   53 ++
 include/net/bluetooth/hci.h                        |   11 +-
 include/net/bluetooth/hci_core.h                   |    8 +-
 include/net/bluetooth/l2cap.h                      |    5 +
 include/net/bluetooth/mgmt.h                       |    2 +-
 include/net/cfg80211.h                             |  107 ++-
 include/net/mac80211.h                             |   40 +-
 include/net/regulatory.h                           |    5 +
 net/bluetooth/a2mp.c                               |    4 +-
 net/bluetooth/hci_conn.c                           |   47 +-
 net/bluetooth/hci_core.c                           |   77 +-
 net/bluetooth/hci_event.c                          |  170 ++---
 net/bluetooth/l2cap_core.c                         |  151 ++--
 net/bluetooth/mgmt.c                               |   60 +-
 net/mac80211/agg-tx.c                              |    3 +-
 net/mac80211/cfg.c                                 |   62 +-
 net/mac80211/debugfs.c                             |    2 -
 net/mac80211/ieee80211_i.h                         |   24 +-
 net/mac80211/iface.c                               |   60 +-
 net/mac80211/key.c                                 |   20 -
 net/mac80211/main.c                                |    3 +-
 net/mac80211/mlme.c                                |   62 +-
 net/mac80211/offchannel.c                          |   12 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    8 +-
 net/mac80211/rx.c                                  |   49 +-
 net/mac80211/scan.c                                |  116 +--
 net/mac80211/status.c                              |    9 +-
 net/mac80211/trace.h                               |    6 +-
 net/mac80211/tx.c                                  |   30 +-
 net/mac80211/util.c                                |   11 +
 net/nfc/hci/core.c                                 |   20 +-
 net/nfc/hci/hcp.c                                  |    2 +-
 net/nfc/nci/core.c                                 |    3 +
 net/wireless/Kconfig                               |   21 +
 net/wireless/chan.c                                |   24 +-
 net/wireless/core.c                                |   79 +--
 net/wireless/core.h                                |   14 +-
 net/wireless/mlme.c                                |   47 +-
 net/wireless/nl80211.c                             |  537 ++++++++++----
 net/wireless/nl80211.h                             |   21 +-
 net/wireless/reg.c                                 |  132 +++-
 net/wireless/reg.h                                 |    8 +-
 net/wireless/scan.c                                |   24 +-
 net/wireless/sme.c                                 |   10 +-
 net/wireless/util.c                                |   17 +-
 net/wireless/wext-compat.c                         |    9 +-
 163 files changed, 5129 insertions(+), 2905 deletions(-)
 create mode 100644 drivers/bcma/driver_chipcommon_nflash.c
 create mode 100644 drivers/bcma/driver_chipcommon_sflash.c
 create mode 100644 drivers/bcma/driver_gmac_cmn.c
 create mode 100644 drivers/bluetooth/hci_h5.c
 create mode 100644 drivers/net/wireless/ath/ath9k/wow.c
 create mode 100644 include/linux/bcma/bcma_driver_gmac_cmn.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQCZNOAAoJEJctW/TcYTgGJZ8P/ixCgcpkFg77RFGaiS5wiaVs
W6KuFvJYDYTgOP/tZuXsz8Xa7a79TRI7YIhQQBBWI0To9KkhT+zU2wQK+v37e6rt
sJO3Sy+Y+LRYNZpxHFKAE4CzpX5iB01ZAv5jktrhahXOOWZvJgoEKaSDS+m2xAKe
6tEVrrU9mvGU3kjkwNvD9CkUJJ/NgNOo04emeM+0K+UkfN/tN0HRS5TX0WHUOgdG
EcSoN2Da6z7ThpvcBvcCVxmbCBq5x047JmV58oqqSft1l16XWPjN8l9iUrfJ9xhB
K4N6Y6cDdL/74ELh+ByMjbifoX/A6fHgiLYeq7t+EhC9ugEGVAo9ks/0PklS/IAW
iNU9Wx511T4EFknTReMUoMmugX4OxoRFNKYOCDublgcIMjrY5zMX/pVcwD0B8w1L
rZGHCPVTfZWBJ0bchgc+4/j7OdClgFisKLCZDcuUjKD9lyX3Eh12megfXwDGiTEn
Je5p9Cb6YMG0JDmbya2qib5zZnDOKUOkgz9vYyGbrhkTwv4/TGPF+UoX6EC5XiJm
2GOxprjcnpOo0vY9thB6FWetBWXRGj3npgGg/HncdJd7aSFO+fa5C8q8JfrxjYP+
d/hX5kT3bbpW3tvml0D8gj8oXyaXRocwUKZhRnPT7WNqHvex88prhIT6xXdDh9qE
nG3lAUUzrM53Ks8J2OJS
=GTle
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--
