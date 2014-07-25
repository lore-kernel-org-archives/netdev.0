From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-07-25
Date: Fri, 25 Jul 2014 11:23:04 -0400
Message-ID: <20140725152303.GA8525@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates intended for the 3.17 stream!

For the mac80211 bits, Johannes says:

"We have a lot of TDLS patches, among them a fix that should make hwsim
tests happy again. The rest, this time, is mostly small fixes."

For the Bluetooth bits, Gustavo says:

"Some more patches for 3.17. The most important change here is the move of
the 6lowpan code to net/6lowpan. It has been agreed with Davem that this
change will go through the bluetooth tree. The rest are mostly clean up and
fixes."

and,

"Here follows some more patches for 3.17. These are mostly fixes to what
we've sent to you before for next merge window."

For the iwlwifi bits, Emmanuel says:

"I have the usual amount of BT Coex stuff. Arik continues to work
on TDLS and Ariej contributes a few things for HS2.0. I added a few
more things to the firmware debugging infrastructure. Eran fixes a
small bug - pretty normal content."

And for the Atheros bits, Kalle says:

"For ath6kl me and Jessica added support for ar6004 hw3.0, our latest
version of ar6004.

For ath10k Janusz added a printout so that it's easier to check what
ath10k kconfig options are enabled. He also added a debugfs file to
configure maximum amsdu and ampdu values. Also we had few fixes as
usual."

On top of that is the usual large batch of various driver updates --
brcmfmac, mwifiex, the TI drivers, and wil6210 all get some action.
Rafa=C5=82 has also been very busy with b43 and related updates.

Also, I pulled the wireless tree into this in order to resolve a
merge conflict...

Please let me know if there are problems!

John

P.S.  The change to fs/compat_ioctl.c reflects a name change in a
Bluetooth header file...

---

The following changes since commit ca424b2022410b6c2cd0bc0f9a0438ed0b75f95f:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/=
git/bluetooth/bluetooth-next (2014-07-10 17:00:34 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-07-25

for you to fetch changes up to 9a244409d0b0cf3b1e46f1dc331f2c718597fae0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless (2014-07-25 10:22:36 -0400)

----------------------------------------------------------------

Alexander Aring (2):
      6lowpan: introduce new net/6lowpan directory
      MAINTAINERS: add net/6lowpan/ maintainer entry

Amitkumar Karwar (4):
      mwifiex: access rx_reorder_tbl_ptr only while holding lock
      mwifiex: fix corner case system hang issue
      Bluetooth: add public address configuration for Marvell USB devices
      Bluetooth: btmrvl: add public address configuration support

Andreas Fenkart (1):
      mwifiex: card reset: enable rescan of non-removable card

Andrew Bresticker (1):
      mac80211_hwsim: fix compiler warning on MIPS

Andrey Utkin (1):
      ath9k: drop negativity checks for unsigned values coming from kstrtou=
l()

Arend van Spriel (7):
      brcmfmac: make use of seq_file API for debugfs entries
      brcmfmac: rework debugfs functions in the driver
      brcmfmac: move attach and detach functions in wl_cfg80211.c
      brcmfmac: introduce feature and quirk handling
      brcmfmac: moving some functions around
      brcmfmac: rework wiphy structure setup
      brcmfmac: add brcmf_p2p_detach() call in brcmf_cfg80211_detach()

Ariej Marjieh (3):
      iwlwifi: mvm: Enabling Aux Queue
      iwlwifi: mvm: Define AUX ROC Command
      iwlwifi: mvm: add Aux ROC request/response flow

Arik Nemtsov (17):
      wlcore: don't switch channels on disconnected STA vifs
      wl18xx: change the number of WLAN addrs per chip
      mac80211: track TDLS initiator internally
      mac80211: fix error path for TDLS setup
      mac80211: consolidate TDLS IE treatment
      mac80211: split extra TDLS IEs in setup frames
      mac80211: avoid adding some IEs on TDLS setup failure packets
      mac80211: set TDLS capab to zero on failure frames
      mac80211: add QoS IE during TDLS setup start
      mac80211: add TDLS QoS param IE on setup-confirm
      mac80211: move TDLS data to mgd private part
      mac80211: support HT for TDLS stations
      mac80211: set Rx highest rate in ht_cap
      mac80211: disable VHT for TDLS
      cfg80211: fix TDLS setup with VHT peers
      mac80211: ignore frames between TDLS peers when operating as AP
      iwlwifi: mvm: teardown TDLS peers during chan-switch and AP DCM

Avinash Patil (1):
      mwifiex: remove needless current_bssid variable

Bing Zhao (6):
      mwifiex: fix a cut-n-paste error in adhoc-start
      mwifiex: define TDLS idle timeout macro with units
      mwifiex: declare sta_ptr in smaller scope
      mwifiex: correct a typo in mwifiex_ret_tdls_oper
      mwifiex: remove redundant TDLS setup action frame check and avoid lea=
ks
      mwifiex: remove redundant timestamps in debug prints

Chin-Ran Lo (1):
      Bluetooth: btmrvl: avoid sending data to firmware after hs_activated

Daniel Kim (1):
      brcmfmac: Make firmware path a module parameter

Eliad Peller (16):
      wlcore: save seq num only between recoveries
      wlcore: user smaller sqn padding for GEM
      wl18xx: fix last tx rate calculation
      wlcore: use correct LAA bit
      wlcore: add smart config definitions
      wlcore/wl18xx: add smart config commands
      wlcore: handle smart config vendor commands
      wlcore/wl18xx: handle smart config events
      wlcore: increase max roc duration to 30 seconds
      wlcore: register vendor commands
      wl18xx: make sure fw_status->priv exists before deref
      wlcore/wl18xx/wl12xx: convert bitmaps to unsigned longs
      cfg80211: fix mic_failure tracing
      iwlwifi: mvm: pass beacons from foreign APs
      iwlwifi: mvm: add some missing iwl_mvm_ref_sync() calls
      iwlwifi: mvm: wait for handlers when stopping scans

Emmanuel Grumbach (13):
      iwlwifi: mvm: fix merge damage
      iwlwifi: mvm: BT Coex - fix TLC with old API
      iwlwifi: fix Kconfig issues
      iwlwifi: mvm: use C99 initializers for add_sta
      iwlwifi: mvm: BT Coex - fix the ACK / CTS kill mask
      iwlwifi: mvm: BT Coex - don't change AP SMPS mode
      iwlwifi: fix inconsistency about power_save module parameter
      iwlwifi: split fw-error-dump between transport and mvm
      iwlwifi: dump periphery registers to fw-error-dump
      iwlwifi: dump CSRs to fw-error-dump
      iwlwifi: mvm: reset beacon filtering and BT Coex data upon FW restart
      Merge branch 'iwlwifi-fixes' into iwlwifi-next
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next

Eran Harary (2):
      iwlwifi: mvm: minor change in debug print
      iwlwifi: mvm: update smart fifo / beacon filtering upon association

Eytan Lifshitz (2):
      iwlwifi: mvm: fix wrong offset while reading from NVM
      mac80211: remove useless NULL checks

Felix Fietkau (3):
      ath9k: fix pending tx frames accounting
      mac80211: fix crash on getting sta info with uninitialized rate contr=
ol
      ath9k: fix aggregation session lockup

Frederic Danis (1):
      ath6kl: Fix ath6kl_bmi_read_hi32 macro

Hante Meuleman (1):
      brcmfmac: Cleanup used device IDs.

Himangi Saraogi (1):
      Bluetooth: cmtp: Remove unnecessary null test

Janusz Dziedzic (2):
      ath10k: print Kconfig options
      ath10k: add implementation for configure max amsdu, ampdu

Jessica Wu (3):
      ath6kl: implement rx flush for htc pipe
      ath6kl: add support wmi rate tables with mcs15
      ath6kl: add support for ar6004 hw3.0

Johan Hedberg (30):
      Bluetooth: Always confirm incoming SMP just-works requests
      Bluetooth: Fix forcing SMP just-works with no-bonding
      Bluetooth: Fix incorrect clearing of SMP_FLAG_INITIATOR
      Bluetooth: Fix advertising parameter update when toggling connectable
      Bluteooth: Reject SMP bonding if HCI_PAIRABLE is not set
      Bluetooth: Fix using test_and_clear instead of test_and_set
      Bluetooth: Remove unneeded mgmt_connectable function
      Bluetooth: Refactor ioctl scan state update to its own function
      Bluetooth: Remove unneeded mgmt_discoverable function
      Bluetooth: Remove unneeded mgmt_write_scan_failed function
      Bluetooth: Fix tracking local SSP authentication requirement
      Bluetooth: Fix trying LTK re-encryption when we don't have an LTK
      Bluetooth: Remove unnecessary params variable from process_adv_report=
()
      Bluetooth: Don't try to reject failed LE connections
      Bluetooth: Add proper defines for HCI connection role
      Bluetooth: Convert HCI_CONN_MASTER flag to a conn->role variable
      Bluetooth: Use explicit role instead of a bool in function parameters
      Bluetooth: Add a role parameter to hci_conn_add()
      Bluetooth: Track number of LE slave connections
      Bluetooth: Fix trying to initiate connections when acting as LE slave
      Bluetooth: Fix always checking the blacklist for incoming connections
      Bluetooth: Fix using uninitialized variable when pairing
      Bluetooth: Don't bother user space without IO capabilities
      Bluetooth: Fix resetting remote authentication requirement after pair=
ing
      Bluetooth: Pass initiator/acceptor information to hci_conn_security()
      Bluetooth: Introduce a flag to track who really initiates authenticat=
ion
      Bluetooth: Fix allowing initiating pairing when not pairable
      Bluetooth: Use EOPNOTSUPP instead of ENOTSUPP
      Bluetooth: Disable HCI_CONNECTABLE based passive scanning for now
      Bluetooth: Prefer sizeof(*ptr) when allocating memory

Johannes Berg (2):
      Revert "mac80211: move "bufferable MMPDU" check to fix AP mode scan"
      mac80211: suppress unused variable warning without lockdep

John W. Linville (9):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge tag 'for-linville-20140717' of git://github.com/kvalo/ath
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge git://git.kernel.org/.../jberg/mac80211-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Kalle Valo (3):
      ath10k: remove unused len variables from wmi process rx functions
      ath6kl: convert ar6004 hardware flags to firmware feature flags
      ath6kl: don't set hi_refclk_hz if hardware version doesn't need it

Liad Kaufman (1):
      mac80211: make sure TDLS teardown packet is sent on time

Lorenzo Bianconi (1):
      ath9k: set up tx power into the MRR

Luciano Coelho (1):
      mac80211: remove redundant IEEE80211_STA_CSA_RECEIVED flag

Luis R. Rodriguez (1):
      wireless: fixup genregdb.awk for remove of antenna gain from wireless=
-regd

Marcel Holtmann (26):
      Bluetooth: Mark controller is down when HCI_AUTO_OFF is set
      Bluetooth: Set HCI_PAIRABLE during power on for legacy ioctl
      Bluetooth: Move HCI socket definitions into its own header file
      Bluetooth: Move struct hci_sec_filter next to its user
      Bluetooth: Delcare the hci_sec_filter as const
      Bluetooth: Move struct hci_pinfo into net/bluetooth/hci_sock.c
      Bluetooth: Move HCI request internals to net/bluetooth/hci_core.c
      Bluetooth: Update the list of L2CAP fixed channels
      Bluetooth: Move struct sco_pinfo into net/bluetooth/sco.c
      Bluetooth: Move struct sco_conn into net/bluetooth/sco.c
      Bluetooth: Remove unused SCO_DEFAULT_FLUSH_TO constant
      Bluetooth: Move SCO timeout constants into net/bluetooth/sco.c
      Bluetooth: Check for valid HCI UART driver flags
      Bluetooth: Add support for external configuration with UART driver
      Bluetooth: Fix HCIUARTGETDEVICE ioctl when UART is not registered
      Bluetooth: Read LE Advertising Channel TX Power only when available
      Bluetooth: Enable LE encryption events only when supported
      Bluetooth: Enable LE Long Term Key Request event only when supported
      Bluetooth: Allocate struct inquiry_entry with GFP_KERNEL
      Bluetooth: Remove unneeded forward declaration of __sco_chan_add
      Bluetooth: Remove unneeded forward declaration of sco_chan_del
      Bluetooth: Convert L2CAP ident spinlock into a mutex
      Bluetooth: Remove sco_chan_get helper function
      Bluetooth: Fix endian and alignment issue with ath3k version handling
      Bluetooth: Remove unneeded variable assignment in hmac_sha256
      Bluetooth: Add support for Broadcom device of Asus Z97-DELUXE motherb=
oard

Max Stepanov (1):
      mac80211: fix a potential NULL access in ieee80211_crypto_hw_decrypt

Michal Kazior (5):
      ath10k: fix unregister deadlock when fw probe fails
      ath10k: fix bmi exchange tx/rx race
      ath10k: sanitize tx ring index access properly
      mac80211: fix Rx reordering with RX_FLAG_AMSDU_MORE
      mac80211: add support for Rx reordering offloading

Oren Givon (1):
      iwlwifi: add max RX aggregation size

Rafa=C5=82 Mi=C5=82ecki (34):
      b43: always print info about radio (manuf, id, revision)
      b43: N-PHY: drop reg 0x1 access restriction on new PHY revs
      b43: N-PHY: add TX gain tables for devices with specific EPA
      b43: N-PHY: add placeholders for new devices support
      b43; N-PHY: write most of the missing code for revs 7+
      b43: N-PHY: init and channel switching of radio 0x2057 rev 9
      b43: N-PHY: implement channel switching of radio 0x2057 rev 5
      b43: enable radio 0x2057 rev 9 (AKA BCM43228) support
      b43: don't warn about no 5 GHz support on 2.4 GHz devices
      b43: N-PHY: add missing TX gain table for radio 0x2057 rev 5
      ssb: make code for antenna gain extraction more generic
      ssb: extract antenna gains from SPROMs revs 4+ properly
      ssb: extract power info from SPROM revs 4 and 5
      bcma: extract antenna gains from SPROM correctly
      bcma: add support for BCM43217 found in Tenda W322E (14e4:43a9)
      b43: N-PHY: fix channel switching with 2 GHz radio 0x2057
      b43: N-PHY: add tables for radio 0x2057 rev 14
      b43: N-PHY: complete 0x2057 radio init calibration
      b43: N-PHY: set band on every channel switch
      b43: use one shared function for setting MAC frequency
      b43: N-PHY: update spur avoidance to support newer devices
      b43: N-PHY: add helper for setting digital filters
      b43: N-PHY: update digital filters setup
      b43: N-PHY: update generic rev7+ workarounds
      b43: N-PHY: allow applying separated workarounds per core
      b43: N-PHY: add rev7+ workarounds for radio revs 9 and 14
      b43: N-PHY: final fixes to rev7+ workarounds
      b43: enable radio 0x2057 rev 14 support (AKA BCM43217)
      b43: extract one more radio parameter: version
      b43: N-PHY: fix rev7+ typos at random places
      b43: report correct rate to mac80211 for 5 GHz packets
      b43: N-PHY: don't calculate values for TSSI if we can't transmit
      b43: register limited amount of 5G channels for BCM43228
      b43: enable 5 GHz support for N-PHY devices

Ujjal Roy (1):
      mwifiex: do not re-associate when already connected

Vladimir Davydov (1):
      Bluetooth: never linger on process exit

Vladimir Kondratiev (7):
      wil6210: support for "sparrow" hardware
      wil6210: export FW/HW versions through debugfs
      wil6210: fix double definition of 'ctx'
      wil6210: fix memory leak on error path in wil_write_file_rxon()
      wil6210: use same mapping table for FW addr translation and debugfs
      wil6210: map RGF_USER_USAGE_1 on the debugfs
      wil6210: add new register region for AGC table

Xose Vazquez Perez (2):
      wireless: rt2x00: add new rt2800usb devices
      wireless: zd1211rw: new url for fw, remove experimental

 MAINTAINERS                                        |    7 +
 drivers/bcma/driver_chipcommon_pmu.c               |    1 +
 drivers/bcma/host_pci.c                            |    1 +
 drivers/bcma/sprom.c                               |   42 +-
 drivers/bluetooth/ath3k.c                          |   29 +-
 drivers/bluetooth/btmrvl_drv.h                     |    1 +
 drivers/bluetooth/btmrvl_main.c                    |   24 +
 drivers/bluetooth/btmrvl_sdio.c                    |   16 +-
 drivers/bluetooth/btusb.c                          |   34 +
 drivers/bluetooth/hci_ldisc.c                      |   25 +-
 drivers/bluetooth/hci_uart.h                       |    1 +
 drivers/net/wireless/ath/ath10k/ce.c               |   11 +-
 drivers/net/wireless/ath/ath10k/core.c             |   12 +-
 drivers/net/wireless/ath/ath10k/core.h             |    3 +
 drivers/net/wireless/ath/ath10k/debug.c            |   73 ++
 drivers/net/wireless/ath/ath10k/htt.h              |   13 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   46 +
 drivers/net/wireless/ath/ath10k/pci.c              |   11 +-
 drivers/net/wireless/ath/ath10k/pci.h              |    3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |    6 -
 drivers/net/wireless/ath/ath6kl/bmi.h              |    3 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    6 +-
 drivers/net/wireless/ath/ath6kl/core.c             |   16 +
 drivers/net/wireless/ath/ath6kl/core.h             |   36 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   32 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   90 +-
 drivers/net/wireless/ath/ath6kl/main.c             |   17 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |    7 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   72 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   10 +-
 drivers/net/wireless/ath/ath9k/spectral.c          |    8 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   34 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   58 +-
 drivers/net/wireless/ath/wil6210/main.c            |   42 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   22 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |    6 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   26 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   21 +-
 drivers/net/wireless/b43/main.c                    |  149 ++-
 drivers/net/wireless/b43/main.h                    |    1 +
 drivers/net/wireless/b43/phy_lcn.c                 |   35 +-
 drivers/net/wireless/b43/phy_n.c                   | 1113 ++++++++++++++++=
----
 drivers/net/wireless/b43/phy_n.h                   |   15 +
 drivers/net/wireless/b43/radio_2057.c              |  420 +++++++-
 drivers/net/wireless/b43/radio_2057.h              |   10 +
 drivers/net/wireless/b43/tables_nphy.c             |  176 +++-
 drivers/net/wireless/b43/xmit.c                    |    7 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   23 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |   28 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |  196 +---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   74 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   13 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  274 +++--
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |  136 +++
 drivers/net/wireless/brcm80211/brcmfmac/feature.h  |   86 ++
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |    5 +
 drivers/net/wireless/brcm80211/brcmfmac/firmware.h |    5 +
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  100 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    4 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   49 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  984 ++++++++---------
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   37 -
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   60 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   25 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    4 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |   17 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   21 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  193 ++--
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |  119 +--
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  104 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |    2 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   67 ++
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   15 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  383 +++++--
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   52 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |    4 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   14 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   24 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   89 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   12 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   10 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  202 +++-
 drivers/net/wireless/mac80211_hwsim.c              |   11 +-
 drivers/net/wireless/mwifiex/11n.c                 |    3 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   27 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    8 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   40 +-
 drivers/net/wireless/mwifiex/fw.h                  |    2 +-
 drivers/net/wireless/mwifiex/join.c                |    8 +-
 drivers/net/wireless/mwifiex/main.c                |   16 +-
 drivers/net/wireless/mwifiex/pcie.c                |   14 +-
 drivers/net/wireless/mwifiex/sdio.c                |   15 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   10 -
 drivers/net/wireless/mwifiex/tdls.c                |   22 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    4 +
 drivers/net/wireless/ti/wl12xx/main.c              |    2 +-
 drivers/net/wireless/ti/wl18xx/cmd.c               |   89 ++
 drivers/net/wireless/ti/wl18xx/cmd.h               |   19 +-
 drivers/net/wireless/ti/wl18xx/event.c             |   65 ++
 drivers/net/wireless/ti/wl18xx/event.h             |    2 +
 drivers/net/wireless/ti/wl18xx/main.c              |   34 +-
 drivers/net/wireless/ti/wl18xx/tx.c                |    7 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    2 +-
 drivers/net/wireless/ti/wlcore/Makefile            |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   12 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    3 +
 drivers/net/wireless/ti/wlcore/debugfs.c           |    2 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |   27 +
 drivers/net/wireless/ti/wlcore/main.c              |  103 +-
 drivers/net/wireless/ti/wlcore/tx.c                |    2 +-
 drivers/net/wireless/ti/wlcore/vendor_cmd.c        |  197 ++++
 drivers/net/wireless/ti/wlcore/vendor_cmd.h        |   45 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |    8 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   20 +-
 drivers/net/wireless/zd1211rw/Kconfig              |    4 +-
 drivers/ssb/pci.c                                  |  113 +-
 fs/compat_ioctl.c                                  |    2 +-
 include/linux/bcma/bcma.h                          |    2 +
 include/linux/ieee80211.h                          |   20 +
 include/linux/ssb/ssb_regs.h                       |   37 +
 include/net/bluetooth/hci.h                        |  156 +--
 include/net/bluetooth/hci_core.h                   |   54 +-
 include/net/bluetooth/hci_sock.h                   |  175 +++
 include/net/bluetooth/l2cap.h                      |   10 +-
 include/net/bluetooth/sco.h                        |   30 -
 include/net/mac80211.h                             |   34 +
 net/6lowpan/Kconfig                                |    6 +
 net/6lowpan/Makefile                               |    3 +
 net/{ieee802154/6lowpan_iphc.c =3D> 6lowpan/iphc.c}  |    0
 net/Kconfig                                        |    1 +
 net/Makefile                                       |    3 +-
 net/bluetooth/Kconfig                              |    3 +-
 net/bluetooth/amp.c                                |    6 +-
 net/bluetooth/cmtp/capi.c                          |    6 -
 net/bluetooth/hci_conn.c                           |   41 +-
 net/bluetooth/hci_core.c                           |  160 ++-
 net/bluetooth/hci_event.c                          |  155 ++-
 net/bluetooth/hci_sock.c                           |   21 +-
 net/bluetooth/l2cap_core.c                         |   40 +-
 net/bluetooth/l2cap_sock.c                         |    7 +-
 net/bluetooth/mgmt.c                               |  122 +--
 net/bluetooth/rfcomm/core.c                        |    3 +-
 net/bluetooth/rfcomm/sock.c                        |    3 +-
 net/bluetooth/sco.c                                |  125 ++-
 net/bluetooth/smp.c                                |   62 +-
 net/ieee802154/Kconfig                             |    9 +-
 net/ieee802154/Makefile                            |    5 +-
 net/mac80211/agg-rx.c                              |  110 +-
 net/mac80211/chan.c                                |    2 +-
 net/mac80211/ht.c                                  |   10 +-
 net/mac80211/ibss.c                                |   13 +-
 net/mac80211/ieee80211_i.h                         |   34 +-
 net/mac80211/iface.c                               |   31 +-
 net/mac80211/key.c                                 |    3 -
 net/mac80211/mlme.c                                |   22 +-
 net/mac80211/rx.c                                  |   65 +-
 net/mac80211/sta_info.c                            |    5 +-
 net/mac80211/sta_info.h                            |    8 +-
 net/mac80211/tdls.c                                |  459 ++++++--
 net/mac80211/tx.c                                  |   20 +-
 net/mac80211/util.c                                |   15 +
 net/mac80211/vht.c                                 |    4 +
 net/mac80211/wpa.c                                 |    2 +-
 net/wireless/Kconfig                               |    6 +
 net/wireless/genregdb.awk                          |   35 +-
 net/wireless/nl80211.c                             |    3 +-
 net/wireless/trace.h                               |    3 +-
 178 files changed, 6583 insertions(+), 2761 deletions(-)
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/feature.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/feature.h
 create mode 100644 drivers/net/wireless/ti/wlcore/vendor_cmd.c
 create mode 100644 drivers/net/wireless/ti/wlcore/vendor_cmd.h
 create mode 100644 include/net/bluetooth/hci_sock.h
 create mode 100644 net/6lowpan/Kconfig
 create mode 100644 net/6lowpan/Makefile
 rename net/{ieee802154/6lowpan_iphc.c =3D> 6lowpan/iphc.c} (100%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT0nZXAAoJEJctW/TcYTgGNxgP/3iqsaFn/BL49vgIWUN9EiqZ
h47lU8RIVPNdcmCqA4GCc4lJD/8qViDI1KsrshLh2Snysht+5sxnUjLwMW+kXlTz
Do+NYDy4MSLHW8RJOXYcWSVR+8CR1I6Km2ZPN++ZWje8oRfU0Cr07GoCxyTg38g9
LJ9yAOkAyXzXwau+UoZh8BKspk3seu6TYM7Uk+Yg5+Ii8SXoxnD6cIDZrCFaPWY2
Pwc3vnqqgeeA6v4F4dH+vZPqO8h9OoODnkcxefyFIOWaH9letWb8Vkd15CcC1Ufh
i1/xCTG59xG71E2WzTdZmmijDkkAAXlS025ZSdQqi88OypeKlGw0Fx6Gp/u/JOvi
yy91FrGt0rRkRf8JCwI7aBuMGJF9wPByDcNpk9lRBwcOQk0JE5b/pgDjGKwlZQ2w
qK1WPW/X0LA76fTBpqpZrLj/Mq9Lyc2k4A7kzb982b5vGNnTykKDp10guQwo6lqK
N9K44nrhcJTda/+TO1F86aShkzIUmm78CLjLXCK8BU4KRlQrVI9styKH64BCUkxJ
Hk4AysNPPUief0dENgRv1/BaYoBLCxZ1St6Iqe9Ml5qLx4Ho4YQfkTQfe08VlpXq
uVk0wJci1sNQ//z5DsECthG3sahg/g6g8l3eXidYHocA5P/Y+By+wO1NwLTOnNTz
AHVY5b9bwFTG09R4xI4Z
=NEs7
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
