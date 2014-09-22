From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-09-22
Date: Mon, 22 Sep 2014 15:45:13 -0400
Message-ID: <20140922194512.GD23806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53190 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbaIVUAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:00:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.18 stream...

For the mac80211 bits, Johannes says:

"This time, I have some rate minstrel improvements, support for a very
small feature from CCX that Steinar reverse-engineered, dynamic ACK
timeout support, a number of changes for TDLS, early support for radio
resource measurement and many fixes. Also, I'm changing a number of
places to clear key memory when it's freed and Intel claims copyright
for code they developed."

For the bluetooth bits, Johan says:

"Here are some more patches intended for 3.18. Most of them are cleanups
or fixes for SMP. The only exception is a fix for BR/EDR L2CAP fixed
channels which should now work better together with the L2CAP
information request procedure."

For the iwlwifi bits, Emmanuel says:

"I fix here dvm which was broken by my last pull request. Arik
continues to work on TDLS and Luca solved a few issues in CT-Kill. Eyal
keeps digging into rate scaling code, more to come soon. Besides this,
nothing really special here."

Beyond that, there are the usual big batches of updates to ath9k, b43,
mwifiex, and wil6210 as well as a handful of other bits here and there.
Also, rtlwifi gets some btcoexist attention from Larry.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 61a3d4f9d52c00b2016bc27fc66b10a194043f76:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless (2014-09-08 11:14:56 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-09-16

for you to fetch changes up to 7a0a260a0f6ff0226c33cf28a5cc26711ab0ae5f:

  ath9k: enable ext channel pulse detection (2014-09-16 16:18:42 -0400)

----------------------------------------------------------------
Amitkumar Karwar (4):
      mwifiex: fix a bug in Tx multiport aggregation
      mwifiex: minor cleanup in multiport aggregation
      mwifiex: remove redundant variable report_scan_result
      mwifiex: remove low priority scan handling

Andy Shevchenko (1):
      hostap: proc: substitute loops by %*phN

Arik Nemtsov (3):
      mac80211: set network header in TDLS frames
      iwlwifi: mvm: move TDLS code to separate file
      iwlwifi: mvm: fix PSM disable during TDLS

Assaf Krauss (3):
      nl80211: Allow declaring RRM-related features
      nl80211: Add flag attribute for RRM connections
      mac80211: Add RRM support to assoc request

Avinash Patil (11):
      mwifiex: set fw api info for backword compatibility
      mwifiex: fix probable memory corruption while processing TDLS frame
      mwifiex: avoid processing RX packets with invalid length
      mwifiex: rework internal scan for association
      mwifiex: support for event done interrupt
      mwifiex: set passive scan type for scan requests with no ssid
      mwifiex: bring in scan channel gap feature
      mwifiex: remove restriction of single channel scan when connected
      mwifiex: process TX even when scan is ongoing
      mwifiex: add rx workqueue support
      mwifiex: modify TX/RX window sizes for AP interface

Avri Altman (2):
      iwlwifi: mvm: remove unused static inline function
      iwlwifi: mvm: Fix skip over dtim configuration in d0i3

Behan Webster (1):
      Bluetooth: LLVMLinux: Remove VLAIS from bluetooth/amp.c

Champion Chen (1):
      Bluetooth: Fix issue with USB suspend in btusb driver

David Spinadel (1):
      iwlwifi: mvm: reduce active dwell time

Dedy Lansky (6):
      wil6210: fix for memory corruption while insmod
      wil6210: fix for memory corruption upon rmmod
      wil6210: fix race condition of disconnect while BACK event
      wil6210: modify confusing printout
      wil6210: fix race condition between BACK event and Rx data
      wil6210: introduce separate completion for WMI

Eliad Peller (9):
      cfg80211: avoid duplicate entries on regdomain intersection
      mac80211: adjust roc duration when combining ROCs
      mac80211: combine roc with the "next roc" if possible
      iwlwifi: increase DEFAULT_MAX_TX_POWER
      cfg80211/mac80211: add wmm info to assoc event
      cfg80211: allow requesting SMPS mode on ap start
      mac80211: set smps_mode according to ap params
      mac80211: replace SMPS hw flags with wiphy feature bits
      iwlwifi: mvm: move IWL_MVM_UAPSD_QUEUES to constants.h

Emmanuel Grumbach (8):
      iwlwifi: mvm: enable scheduled scan on newest firmware
      iwlwifi: mvm: fix endianity issues with Smart Fifo commands
      iwlwiwi: mvm: use bss_conf->dtim_period instead of conf.ps_dtim_period
      iwlwifi: dvm: disable power save by default
      Merge remote-tracking branch 'iwlwifi-fixes/master' into NEXT
      iwlwifi: trans: don't configure the set_active in SCD for dvm
      iwlwifi: define the non shared antenna per hardware
      iwlwifi: mvm: allow to collect debug data when restart is disabled

Eran Harary (1):
      iwlwifi: mvm: allow preventing dummy notifications

Eyal Shapira (7):
      mac80211: fix broken use of VHT/20Mhz with some APs
      iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate
      iwlwifi: mvm: fix an overflow in iwl_mvm_get_signal_strength
      iwlwifi: mvm: add LDPC support
      iwlwifi: enable LDPC in 8000 chip family
      iwlwifi: mvm: rs: remove max_rate_idx
      iwlwifi: mvm: rs: don't zero tx stats after idle

Fabian Frederick (2):
      brcm80211: use container_of to resolve brcms_phy from brcms_phy_pub
      brcm80211: use container_of to resolve dma_info from dma_pub

Hans Wennborg (2):
      iwl4965: fix %d confusingly prefixed with 0x in format string
      rtlwifi: fix %d confusingly prefixed with 0x in format strings

Hauke Mehrtens (7):
      bcma: store more alternative addresses
      bcma: add support for chipcommon B core
      b43: tell the ucode the mac capabilities
      b43: tell ucode the phy type and version
      b43: add missing rate
      b43: update some transmit header constants
      b43: add support for setting the beacon listen interval

Johan Hedberg (41):
      Bluetooth: Fix incorrect LE CoC PDU length restriction based on HCI M=
TU
      Bluetooth: Remove unnecessary l2cap_chan_unlock before l2cap_chan_add
      Bluetooth: Fix hci_conn reference counting for fixed channels
      Bluetooth: Set addr_type only when it's needed
      Bluetooth: Optimize connection parameter lookup for LE connections
      Bluetooth: Improve *_get() functions to return the object type
      Bluetooth: Fix using hci_conn_get() for hci_conn pointers
      Bluetooth: Refactor connection parameter freeing into its own function
      Bluetooth: Use zero timeout for immediate scheduling
      Bluetooth: Fix hci_conn reference counting with hci_chan
      Bluetooth: Set disc_timeout to 0 when calling hci_chan_del
      Bluetooth: Ignore incoming data after initiating disconnection
      Bluetooth: Remove hci_conn_hold/drop from hci_chan
      Bluetooth: Set discon_timeout to 0 in l2cap_conn_del
      Bluetooth: Use hci_disconnect for immediate disconnection from SMP
      Bluetooth: Remove unused l2cap_conn_shutdown API
      Bluetooth: Fix SMP error and response to be mutually exclusive
      Bluetooth: Update hci_disconnect() to return an error value
      Bluetooth: Use hci_disconnect() for mgmt_disconnect_device()
      Bluetooth: Move clock offset reading into hci_disconnect()
      Bluetooth: Add clarifying comment for LE CoC result value
      Bluetooth: Remove unnecessary checks after canceling SMP security tim=
er
      Bluetooth: Don't take any action in smp_resume_cb if not encrypted
      Bluetooth: Move identity address update behind a workqueue
      Bluetooth: Remove unnecessary deferred work for SMP key distribution
      Bluetooth: Fix locking of the SMP context
      Bluetooth: Add define for key distribution mask
      Bluetooth: Fix calling smp_distribute_keys() when still waiting for k=
eys
      Bluetooth: Add strict checks for allowed SMP PDUs
      Bluetooth: Fix dereferencing conn variable before NULL check
      Bluetooth: Fix mgmt pairing failure when authentication fails
      Bluetooth: Fix allowing SMP Signing info PDU
      Bluetooth: Remove unnecessary early initialization of variable
      Bluetooth: Fix ignoring unknown SMP authentication requirement bits
      Bluetooth: Centralize disallowing SMP commands to a single place
      Bluetooth: Fix SMP security level when we have no IO capabilities
      Bluetooth: Add smp_ltk_sec_level() helper function
      Bluetooth: Fix L2CAP information request handling for fixed channels
      Bluetooth: Avoid hard-coded IO capability values in SMP
      Bluetooth: Expire RPA if encryption fails
      Bluetooth: Fix re-setting RPA as expired when deferring update

Johannes Berg (19):
      mac80211: clean up ieee80211_i.h
      mac80211: add Intel Mobile Communications copyright
      cfg80211: add Intel Mobile Communications copyright
      iwlwifi: mvm: BT Coex - remove shadowing variable
      iwlwifi: mvm: correctly handle PM/QoS changes from mac80211
      iwlwifi: mvm: BT Coex - always initialize smps_mode
      mac80211: annotate MMIC head/tailroom warning
      cfg80211: clear connect keys when freeing them
      mac80211: clear key material when freeing keys
      cfg80211: clear wext keys when freeing and removing them
      cfg80211: don't put kek/kck/replay counter on the stack
      cfg80211: clear nl80211 messages carrying keys after processing
      cfg80211: add WMM traffic stream API
      iwlwifi: mvm: disable aggregation queues in station DB in FW
      iwlwifi: pcie: clear command data on freeing
      iwlwifi: mvm: don't update quota in firmware too often
      iwlwifi: mvm: update d0i3 debugfs
      iwlwifi: mvm: fix quota update avoidance
      iwlwifi: mvm: update QoS parameters when they change

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'mac80211-next-for-john-2014-09-12' of git://git.kernel.org=
/.../jberg/mac80211-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next

Jukka Rissanen (3):
      Bluetooth: 6lowpan: Increase the connection timeout value
      Bluetooth: 6lowpan: Set the peer IPv6 address correctly
      Bluetooth: 6lowpan: Route packets that are not meant to peer via corr=
ect device

Larry Finger (10):
      rtlwifi: btcoexist: Modify btcoexist for changes in the V062814 Realt=
ek version
      rtlwifi: btcoexist: Modify rtl_btc for changes in latest Realtek code
      rtlwifi: btcoexist: Modify driver for V062814 Realtek driver
      rtlwifi: btcoexist: Modify driver to support BT coexistence in rtl872=
3be
      rtlwifi: btcoexist: Add BT coexistence routines for driver rtl8821ae
      rtlwifi: btcoexist: Add second part of BT coexistence routines for rt=
l8821ae
      rtlwifi: btcoexist: Update remaining old parts of the driver
      rtlwifi: btcoexist: Fix "always true" warning from commit ed364abffd6e
      rtlwifi: btcoexist: avoid format string in printk
      rtlwifi: btcoexist: Change local debugging macros CL_*** into the sta=
ndard varieties

Liad Kaufman (3):
      mac80211: fix description comment of ieee80211_subif_start_xmit
      mac80211: add TDLS connection timeout
      iwlwifi: make hw rev checking more readable

Lorenzo Bianconi (14):
      cfg80211: enable dynack through nl80211
      mac80211: extend set_coverage_class signature
      ath9k: fix radar parameters initialization
      ath9k: export methods related to ACK timeout estimation
      ath9k: add duration field to ath_tx_status
      ath9k: add dynamic ACK timeout estimation
      ath9k: add config for (en|dis)abling ACK timeout estimation
      ath9k: do not overwrite ACK timeout estimation
      ath9k: add sampling methods for (tx|rx) timestamp
      ath9k: enable control frame reception
      ath9k: add debugfs support for dynack
      ath9k: enable dynack using set_coverage_class codepath
      ath9k: initialize ath_node linked list
      ath9k: enable ext channel pulse detection

Luciano Coelho (5):
      iwlwifi: mvm: set MAC_FILTER_IN_BEACON correctly for STA/P2P client
      iwlwifi: mvm: reset ucode_loaded flag when mac80211 stop is called
      iwlwifi: mvm: fail temp test enabling if the ucode is not loaded
      iwlwifi: mvm: use the firmware to get the temperature during CT kill
      iwlwifi: mvm: align CSA GO NOA time event naming with the firmware

Max Stepanov (1):
      iwlwifi: mvm: add MVM_FW_MCAST_FILTER_PASS_ALL option

Michal Kazior (1):
      mac80211: fix offloaded BA session traffic after hw restart

Oren Givon (2):
      iwlwifi: add PCI IDs and add then new 3165 series
      iwlwifi: add and edit 8000 series PCI IDs

Rafa=C5=82 Mi=C5=82ecki (12):
      bcma: move bus struct setup into early part of host specific code
      bcma: use separated function to initialize bus on SoC
      bcma: move code for core registration into separate function
      bcma: register NAND and QSPI cores early
      b43: HT-PHY: Move radio preparation into init function
      b43: HT-PHY: Move radio calibration to separated functions
      b43: HT-PHY: Define some regs for 0x2059 radio
      b43: HT-PHY: Complete radio init (add missing entries)
      b43: HT-PHY: Set MAC frequency to correct values
      b43: HT-PHY: Implement band switching
      b43: HT-PHY: Update values for frequency calibration
      b43: Implement PHY PLL reset

Steinar H. Gunderson (2):
      mac80211: split 802.11h parsing from transmit power policy
      mac80211: support DTPC IE (from Cisco Client eXtensions)

Sujith Manoharan (26):
      ath9k: Fix beacon configuration for channel contexts
      ath9k: Fix beacons for managed mode
      ath9k: Fix panic when adding an AP interface
      ath9k: Fix NoA start time calculation
      ath9k: Fix offchannel duration calculation
      ath9k: Add CTWindow support
      ath9k: Fix RX filter calculation
      ath9k: Fix ath_startrecv()
      ath9k: Fix COMP_BAR filter
      ath9k: Fix RX filters in channel contexts
      ath9k: Fix interface accounting
      ath9k: Use a subroutine to assign HW queues
      ath9k: Fix offchannel operation
      ath9k: Fix MCC scanning
      ath9k: Assign offchannel duration properly
      ath9k: Fix Notice of Absence issues
      ath9k: Clear offchannel duration properly
      ath9k: Fix channel switch time duration
      ath9k: Fix beacon miss handling
      ath9k: Fix beacon processing in offchannel
      ath9k: Remove unnecessary tbtt assignment
      ath9k: Check beaconing mode properly
      ath9k: Set offchannel state properly
      ath9k: Remove useless opmode check
      ath9k: Fix primary station configuration
      ath9k: Fix build error

Thomas Huehn (2):
      mac80211: Unify rate statistic variables between Minstrel & Minstrel_=
HT
      mac80211: improve minstrel_ht rate sorting by throughput & probability

Toralf F=C3=B6rster (1):
      iwlwifi/iwl-drv.c: fix typo defualt -> default

Vladimir Kondratiev (17):
      wil6210: firmware download
      wil6210: debug prints for vring de-allocation
      wil6210: print more information when connecting
      wil6210: some more debug for the WMI mechanism
      wil6210: coding style fixes
      wil6210: platform specific module
      wil6210: add more debug printouts
      wil6210: fix usage of print_hex_dump_debug
      wil6210: send connect request IEs to FW also for non-secure connection
      wil6210: add change_beacon() driver callback
      wil6210: enlarge TX/RX buffer length
      wil6210: specify max. IE length
      wil6210: fix typo in comment
      wil6210: rename [en|dis]able irq to [un]mask
      wil6210: fix for oops while stopping interface
      wil6210: fix PTR_ERR() usage after initialization to constant
      fixup! wil6210: fix usage of print_hex_dump_debug

Xinming Hu (1):
      mwifiex: fix 5G association failure after leaving 2.4G IBSS

 arch/mips/bcm47xx/setup.c                          |    4 +
 drivers/bcma/Makefile                              |    1 +
 drivers/bcma/bcma_private.h                        |    4 +
 drivers/bcma/driver_chipcommon_b.c                 |   61 +
 drivers/bcma/host_pci.c                            |    3 +
 drivers/bcma/host_soc.c                            |   14 +-
 drivers/bcma/main.c                                |  100 +-
 drivers/bcma/scan.c                                |   17 +-
 drivers/bluetooth/btusb.c                          |    9 +
 drivers/net/wireless/ath/ath.h                     |    2 +
 drivers/net/wireless/ath/ath10k/mac.c              |    5 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    2 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    9 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    7 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    9 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |   25 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   14 +-
 drivers/net/wireless/ath/ath9k/channel.c           |  192 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   30 +-
 drivers/net/wireless/ath/ath9k/dynack.c            |  351 ++
 drivers/net/wireless/ath/ath9k/dynack.h            |  103 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   22 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    7 +
 drivers/net/wireless/ath/ath9k/init.c              |    7 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |  173 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   51 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    2 +-
 drivers/net/wireless/ath/ath9k/wow.c               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    5 +
 drivers/net/wireless/ath/wil6210/Kconfig           |    9 +
 drivers/net/wireless/ath/wil6210/Makefile          |    3 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  126 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   60 +-
 drivers/net/wireless/ath/wil6210/fw.c              |   45 +
 drivers/net/wireless/ath/wil6210/fw.h              |  149 +
 drivers/net/wireless/ath/wil6210/fw_inc.c          |  495 +++
 drivers/net/wireless/ath/wil6210/interrupt.c       |   31 +-
 drivers/net/wireless/ath/wil6210/main.c            |  185 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   17 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   39 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   13 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   66 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    9 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   50 +-
 drivers/net/wireless/ath/wil6210/wil_platform.c    |   49 +
 drivers/net/wireless/ath/wil6210/wil_platform.h    |   34 +
 .../net/wireless/ath/wil6210/wil_platform_msm.c    |  257 ++
 .../net/wireless/ath/wil6210/wil_platform_msm.h    |   24 +
 drivers/net/wireless/ath/wil6210/wmi.c             |   40 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   18 +-
 drivers/net/wireless/b43/b43.h                     |    9 +
 drivers/net/wireless/b43/main.c                    |   71 +-
 drivers/net/wireless/b43/main.h                    |    2 +
 drivers/net/wireless/b43/phy_ht.c                  |  205 +-
 drivers/net/wireless/b43/phy_ht.h                  |    7 +-
 drivers/net/wireless/b43/phy_n.c                   |    2 +-
 drivers/net/wireless/b43/radio_2059.c              |  341 +-
 drivers/net/wireless/b43/radio_2059.h              |   14 +
 drivers/net/wireless/b43/xmit.h                    |   22 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |   38 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |  122 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    8 +-
 drivers/net/wireless/hostap/hostap_proc.c          |    6 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    7 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    4 +-
 drivers/net/wireless/iwlwifi/dvm/power.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   31 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    9 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   10 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    3 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    2 +
 drivers/net/wireless/iwlwifi/iwl-io.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    8 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    2 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |   13 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    8 +
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |    3 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   15 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   40 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    3 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   20 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  183 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   30 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |    3 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   18 +
 drivers/net/wireless/iwlwifi/mvm/power.c           |   67 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   32 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   68 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   10 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |    6 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    4 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |    6 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   12 +-
 drivers/net/wireless/iwlwifi/mvm/tdls.c            |  149 +
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   10 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    8 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |  326 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   10 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    8 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    2 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    3 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   12 +-
 drivers/net/wireless/mac80211_hwsim.c              |    8 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   14 +
 drivers/net/wireless/mwifiex/cfg80211.c            |   15 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    4 +
 drivers/net/wireless/mwifiex/decl.h                |    4 +-
 drivers/net/wireless/mwifiex/fw.h                  |   10 +-
 drivers/net/wireless/mwifiex/init.c                |   21 +-
 drivers/net/wireless/mwifiex/main.c                |  191 +-
 drivers/net/wireless/mwifiex/main.h                |   48 +-
 drivers/net/wireless/mwifiex/pcie.c                |   37 +-
 drivers/net/wireless/mwifiex/pcie.h                |    5 +-
 drivers/net/wireless/mwifiex/scan.c                |  112 +-
 drivers/net/wireless/mwifiex/sdio.c                |   28 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 -
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    9 +-
 drivers/net/wireless/mwifiex/tdls.c                |    4 +-
 drivers/net/wireless/p54/main.c                    |    3 +-
 .../net/wireless/rtlwifi/btcoexist/halbt_precomp.h |    6 +
 .../wireless/rtlwifi/btcoexist/halbtc8192e2ant.c   | 3849 ++++++++++++++++=
+++
 .../wireless/rtlwifi/btcoexist/halbtc8192e2ant.h   |  185 +
 .../wireless/rtlwifi/btcoexist/halbtc8723b1ant.c   | 3170 ++++++++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8723b1ant.h   |  184 +
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.c   |  550 +--
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.h   |   31 +-
 .../wireless/rtlwifi/btcoexist/halbtc8821a1ant.c   | 2970 +++++++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8821a1ant.h   |  188 +
 .../wireless/rtlwifi/btcoexist/halbtc8821a2ant.c   | 3879 ++++++++++++++++=
++++
 .../wireless/rtlwifi/btcoexist/halbtc8821a2ant.h   |  205 ++
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  |   52 +-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |  122 +-
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.c   |   27 +-
 drivers/net/wireless/rtlwifi/btcoexist/rtl_btc.h   |    6 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   |    4 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   15 +-
 drivers/usb/host/bcma-hcd.c                        |    2 +-
 include/linux/bcma/bcma.h                          |    4 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |    8 +
 include/linux/bcma/bcma_soc.h                      |    1 +
 include/linux/ieee80211.h                          |    8 +-
 include/net/bluetooth/hci_core.h                   |   14 +-
 include/net/bluetooth/l2cap.h                      |   10 +-
 include/net/cfg80211.h                             |   44 +-
 include/net/mac80211.h                             |   20 +-
 include/uapi/linux/nl80211.h                       |  100 +
 net/bluetooth/6lowpan.c                            |   80 +-
 net/bluetooth/amp.c                                |   13 +-
 net/bluetooth/hci_conn.c                           |   49 +-
 net/bluetooth/hci_core.c                           |   30 +-
 net/bluetooth/hci_event.c                          |   33 +-
 net/bluetooth/hidp/core.c                          |   10 +-
 net/bluetooth/l2cap_core.c                         |  120 +-
 net/bluetooth/l2cap_sock.c                         |    8 +
 net/bluetooth/mgmt.c                               |   37 +-
 net/bluetooth/smp.c                                |  272 +-
 net/bluetooth/smp.h                                |   10 +
 net/mac80211/agg-rx.c                              |    5 +-
 net/mac80211/cfg.c                                 |  101 +-
 net/mac80211/debugfs.c                             |    6 +-
 net/mac80211/debugfs_netdev.c                      |    4 +-
 net/mac80211/debugfs_sta.c                         |    1 +
 net/mac80211/driver-ops.h                          |    2 +-
 net/mac80211/ibss.c                                |    1 +
 net/mac80211/ieee80211_i.h                         |    8 +-
 net/mac80211/iface.c                               |   15 +-
 net/mac80211/key.c                                 |    3 +-
 net/mac80211/main.c                                |    1 +
 net/mac80211/mlme.c                                |  131 +-
 net/mac80211/rc80211_minstrel.c                    |   98 +-
 net/mac80211/rc80211_minstrel.h                    |   43 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |   19 +-
 net/mac80211/rc80211_minstrel_ht.c                 |  303 +-
 net/mac80211/rc80211_minstrel_ht.h                 |   41 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |   10 +-
 net/mac80211/rx.c                                  |   11 +
 net/mac80211/scan.c                                |    1 +
 net/mac80211/sta_info.c                            |    1 +
 net/mac80211/sta_info.h                            |    7 +
 net/mac80211/status.c                              |   22 +-
 net/mac80211/tdls.c                                |    4 +
 net/mac80211/trace.h                               |    4 +-
 net/mac80211/tx.c                                  |    6 +-
 net/mac80211/util.c                                |   26 +
 net/mac80211/wme.c                                 |    1 +
 net/mac80211/wpa.c                                 |    7 +-
 net/wireless/chan.c                                |    1 +
 net/wireless/core.c                                |    3 +-
 net/wireless/ibss.c                                |    4 +-
 net/wireless/mlme.c                                |    4 +-
 net/wireless/nl80211.c                             |  233 +-
 net/wireless/nl80211.h                             |    3 +-
 net/wireless/rdev-ops.h                            |   31 +
 net/wireless/reg.c                                 |   82 +-
 net/wireless/scan.c                                |    1 +
 net/wireless/sme.c                                 |    6 +-
 net/wireless/trace.h                               |   45 +
 net/wireless/util.c                                |    3 +-
 net/wireless/wext-compat.c                         |    2 +
 net/wireless/wext-sme.c                            |    2 +-
 210 files changed, 20726 insertions(+), 2404 deletions(-)
 create mode 100644 drivers/bcma/driver_chipcommon_b.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dynack.c
 create mode 100644 drivers/net/wireless/ath/ath9k/dynack.h
 create mode 100644 drivers/net/wireless/ath/wil6210/fw.c
 create mode 100644 drivers/net/wireless/ath/wil6210/fw.h
 create mode 100644 drivers/net/wireless/ath/wil6210/fw_inc.c
 create mode 100644 drivers/net/wireless/ath/wil6210/wil_platform.c
 create mode 100644 drivers/net/wireless/ath/wil6210/wil_platform.h
 create mode 100644 drivers/net/wireless/ath/wil6210/wil_platform_msm.c
 create mode 100644 drivers/net/wireless/ath/wil6210/wil_platform_msm.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/tdls.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.h
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUIHxIAAoJEJctW/TcYTgG8vQP/AqvTlAW7fdL0EK5EaTh/dl5
IFXOgMaKe+e99iheZZECza122ko3eT+iiVX6oWK6XQm6auC0iblRdNuc/kMOZYM1
dzIqUI2F3EnqcCjOjci9g8EbQPPImKdjJKHqgwkjdOE+yhj86jk+10AcZHpScueH
pgwERjFQSRhO5eJYV3ejkw2AAhPCiG0G/mpujA7E0hYlMjrURxTTsTfBmFJld+lu
2xBV9cMf2k/gv42C5Q3H7TIdNtb5FYV9KGy88wcZ4kZXF3dZcnSUUC40hBXEjqXv
+ofMz9lV68if8z57yONyUz2jpO7tGZQywkL6SgiBHRGAY9LeFPedrQKRpWtuJ8Jf
em2ttc5kTHjZ7pXvADkvBtrvDyzI3i8GkQjcNucQKyCAj25vlQo5tO31jgMX35cY
iO7jLwDbwlKoGa+8nZbGMPNrh2HCT9VLK+M3XwZck/Udh95itP+PhomPm5Elk3MJ
7gXdKBry7jHlUOG+pOgM9aZMjt+um/s8wiLBHF6VwgJo7G6FjgIANvX2R5BjDAkZ
Ldc/15rsLg0W+2XcidR4n0ddDNW+5RqZwM6QYys3ny0jIHVlMGhThra/h8N4QyEH
27HlZRmAdXTVx++rCiQhrS8o2Ig6XNnu3DSLvmi2HLPk0YTwba50TuBBe6BaLzo3
QpSG8a06Z0cV/U4rohfl
=z7jr
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
