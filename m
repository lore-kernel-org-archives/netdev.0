From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2014-01-17
Date: Fri, 17 Jan 2014 15:00:29 -0500
Message-ID: <20140117200028.GC15145@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of updates for the 3.14 stream!

For the mac80211 bits, Johannes says:

"This time I have uAPSD fixes since I was working on that, hwsim
improvements to make dynamic radios possible for the test suite, the
evidently long-overdue channel_change_time removal and a few other small
collected fix and improvements."

For the iwlwifi bits, Emmanuel says:

"Besides a few trivial patches, I have an important workaround for a HW
issue that has kept me busy for a long time. Along with it, a fix that
prevents an error from being printed.
Eyal fixes our behavior against SISO APs and Ilan fixes an issue with
multiple interface scenarios.
Eliad fixes an error path in our init flow.
We also have a few 'static analyzers' fix."

For the NFC bits, Samuel says:

"It includes:

* A new NFC driver for Marvell's 8897, and a few NCI fixes and
  improvements needed to support this chipset.

* An LLCP fix for how we were setting the default MIU on a p2p link. If
  there is no explicit MIU extension announced at connection time, we
  must use the default one and not the one announced at LLCP link
  establishement time.

* A pn544 EEPROM config update. Some of the currently EEPROM configured
  values are overwriting the firmware ones while other should not be set
  by the driver itself.

* Some NFC digital stack fixes and improvements. Asynchronous functions
  are better documented, RF technologies and CRC functions are set upon
  PSL_REQ reception, and a few minor bugs are fixed.

* Minor and miscelaneous pn533, mei_phy and port100 fixes."

For the ath bits, Kalle says:

"Janusz added Kconfig option for DFS. The DFS code was there already, but
after fixes to mac80211 we can now enable it.

Bartosz added a runtime firmware feature flag to disable P2P. Our 10.1
firmware branch doesn't support P2P and ath10k can now disable that. He
also added a limit for how many clients can connect to ath10k AP.

Michal fixed WEP shared authentication, in case someone still uses it.
And I added firmware debug log to help the firmware engineers."

Along with that is a small batch of ath9k updates and a few other bits
here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit cf84eb0b09c0f09b4c70a648b9dfeec78be61f07:

  Merge branch 'virtio_rx_merging' (2014-01-16 23:46:17 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 7916a075571f0ccd0830cf3da293188a8b6045e3:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-01-17 14:43:17 -0500)

----------------------------------------------------------------

Alex Gal (1):
      wl12xx: fix tx power setting

Alexey Khoroshilov (1):
      NFC: port100: Fix device leak

Amitkumar Karwar (8):
      NFC: NCI: Cancel cmd_timer in nci_close_device()
      NFC: NCI: Don't reverse local general bytes
      NFC: NCI: Add setup handler
      NFC: NCI: Add set_config API
      NFC: nfcmrvl: Initial commit for Marvell NFC driver
      NFC: nfcmrvl: Add setup handler
      NFC: nfcmrvl: Fix possible memory leak issue
      mwifiex: add missing endian conversion for fw_tsf

Arend van Spriel (5):
      brcmfmac: rework firmware download code
      brcmfmac: restructure brcmf_sdio_chip_recognition()
      brcmfmac: rename chip and core related structures
      brcmfmac: initialize escan function pointer during scheduled scan
      brcmfmac: handle SDIO card removal

Arman Uguray (1):
      NFC: pn544: Refactor hw_config values

Avinash Patil (2):
      ieee80211: add definition for TDLS wide band extended capability
      ieee80211: add definition for SMS4 key len

Bartosz Markowski (3):
      ath10k: split the if_limits and if_comb
      ath10k: introduce NO_P2P fw feature flag
      ath10k: track number of existing peers

Bing Zhao (1):
      mwifiex: fix wrong 11ac bits setting in fw_cap_info

Chun-Yeow Yeoh (1):
      mac80211: enable WME for peer mesh STA

Dan Carpenter (1):
      p54: clamp properly instead of just truncating

David Spinadel (1):
      iwlwifi: mvm: add REPLY_SF_CFG_CMD to cmd strings

Eliad Peller (2):
      iwlwifi: mvm: fix missing cleanup in .start() error path
      iwlwifi: mvm: fix tx seq_ctrl debug print

Emmanuel Grumbach (9):
      mac80211: clean up garbage in comment
      mac80211: simplify code in ieee80211_prepare_and_rx_handle
      mac80211: allow to set smps mode to OFF in AP mode
      iwlwifi: mvm: don't set the drain bit when we flush the AP station
      iwlwifi: pcie: enable oscillator for L1 exit
      iwlwifi: mvm: send all the NVM sections to the NIC
      iwlwifi: mvm: fix SRAM dump debugfs handler
      iwlwifi: mvm: remove unused flags from add station command
      iwlwifi: mvm: reset Thermal Throttling's SMPS request upon disassocia=
tion

Eyal Shapira (4):
      iwlwifi: mvm: rs: fix handling of column switch error
      iwlwifi: mvm: rs: fix a theoretical out of bounds access
      iwlwifi: change beamformee STS cap
      iwlwifi: mvm: don't use highest rate in VHT MCS Set

Eytan Lifshitz (1):
      iwlwifi: mvm: fix theoretical uninitialized function return value

Hante Meuleman (2):
      brcmfmac: Create common nvram parsing routines.
      brcmfmac: update core reset and disable routines.

Ilan Peer (3):
      cfg80211: Add a function to get the number of supported channels
      iwlwifi: mvm: clear ap_ibss_active in case of failure
      iwlwifi: mvm: update power after binding in start_ap_ibss()

Janusz Dziedzic (3):
      ath10k: handle TKIP MIC error correctly
      ath10k: add DFS_CERTIFIED option
      ath10k: add set_bitrate_mask callback

Johannes Berg (28):
      cfg80211/mac80211: correct qos-map locking
      mac80211: add tracing for ieee80211_sta_set_buffered
      nl80211: move vendor/testmode event skb functions out of ifdef
      mac80211: clean up netdev debugfs macros a bit
      mac80211: handle station TX latency allocation errors
      mac80211: fix memory leak in register_hw() error path
      mac80211_hwsim: fix a print message
      mac80211: clean up prepare_for_handlers() return value
      mac80211: remove channel_change_time
      mac80211: fix PS-Poll driver release TID
      mac80211: release multiple ACs in uAPSD, fix more-data bug
      mac80211: reset TX info flags when frame will be reprocessed
      mac80211: handle MMPDUs at EOSP correctly
      mac80211_hwsim: clean up netlink exit code
      mac80211_hwsim: prepare for different channel support
      mac80211_hwsim: remove regtest for now
      mac80211_hwsim: refactor radio registration
      mac80211_hwsim: refactor radio cleanup
      mac80211_hwsim: minimize rctbl module parameter usage
      mac80211_hwsim: assign index from separate counter
      mac80211_hwsim: minor netlink cleanups
      mac80211_hwsim: shuffle code to prepare for dynamic radios
      mac80211_hwsim: verify wmediumd socket
      mac80211_hwsim: register netlink even with multi-channel
      mac80211_hwsim: allow creating/destroying radios on the fly
      mac80211_hwsim: restore regulatory testing functionality
      iwlwifi: mvm: use array indexing instead of treating it as a pointer
      iwlwifi: add inline helper for packet lengths

John W. Linville (5):
      Merge tag 'nfc-next-3.14-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Julia Lawall (1):
      brcmsmac: delete useless variable

Kalle Valo (4):
      Merge remote-tracking branch 'wireless-next/master' into ath-next
      ath10k: handle WMI debug print events
      ath10k: add trace event for WMI_DEBUG_MESG_EVENTID
      ath10k: add debugfs file to control firmware dbglog

Larry Finger (4):
      rtlwifi: rtl8192cu: Add new device ID
      b43: Fix lockdep splat
      b43: Fix unload oops if firmware is not available
      b43legacy: Fix unload oops if firmware is not available

Luis R. Rodriguez (2):
      ath: fix warning on usage of REGULATORY_CUSTOM_REG
      cfg80211: make regulatory_hint() remove REGULATORY_CUSTOM_REG

Marek Puzyniak (1):
      ath10k: disable STA kickout in FW

Michal Kazior (2):
      ath10k: fix WEP Shared authentication
      ath10k: fix band reporting for mgmt CCK frames on 5GHz

Oleksij Rempel (5):
      ath: add common function ath_is_mybeacon
      ath9k: use ath_is_mybeacon
      ath9k_htc: use ath_is_mybeacon
      ath5k: use ath_is_mybeacon
      carl9170: use ath_is_mybeacon

Salil Kapur (1):
      NFC: mei_phy: Using kfree_skb() instead of kfree()

Samuel Ortiz (3):
      NFC: Return driver failure upon unknown event reception
      NFC: Only warn on SE discovery error
      NFC: pn533: Frame is invalid if ccid.datalen is 0

Sujith Manoharan (9):
      ath9k: Add an option for station statistics
      ath9k: Show only active TIDs in node_aggr
      ath9k: Use a separate debugfs file for PHY errors
      ath9k: Add a debugfs file "node_recv"
      ath9k: Remove debug print in ISR
      ath9k: Process GTT interrupts
      ath9k: Fix error reported by smatch
      ath9k: Fix IQ calibration
      ath9k: Fix possible overflow condition

Szymon Janc (2):
      NFC: llcp: Fix possible memory leak while sending I frames
      NFC: llcp: Use default MIU if none was specified on connect

Thierry Escande (5):
      NFC: digital: Add a note about asynchronous functions
      NFC: digital: Fix incorrect use of ERR_PTR and PTR_ERR macros
      NFC: digital: Use NFC_NFCID3_MAXSIZE from nfc.h
      NFC: digital: Set current target active on activate_target() call
      NFC: digital: Set rf tech and crc functions when receiving a PSL_REQ

Thomas Pedersen (1):
      mac80211: sync dtim_count to TSF

Ujjal Roy (3):
      cfg80211: fix wext-compat for getting retry value
      cfg80211: add sanity check for retry limit in wext-compat
      mwifiex: export threshold value and retry limit to cfg80211

Vladimir Kondratiev (1):
      wil6210: correct #include for prefetch()

Yogesh Ashok Powar (1):
      mwifiex: add USB8897 support

 drivers/net/wireless/adm8211.c                     |    1 -
 drivers/net/wireless/at76c50x-usb.c                |    1 -
 drivers/net/wireless/ath/ath.h                     |    2 +
 drivers/net/wireless/ath/ath10k/Kconfig            |    7 +
 drivers/net/wireless/ath/ath10k/core.h             |   11 +
 drivers/net/wireless/ath/ath10k/debug.c            |   66 ++
 drivers/net/wireless/ath/ath10k/htt.h              |    1 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   15 +
 drivers/net/wireless/ath/ath10k/hw.h               |    1 +
 drivers/net/wireless/ath/ath10k/mac.c              |  375 +++++-
 drivers/net/wireless/ath/ath10k/trace.h            |   21 +
 drivers/net/wireless/ath/ath10k/txrx.c             |    2 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  106 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   61 +
 drivers/net/wireless/ath/ath5k/base.c              |   34 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    8 +
 drivers/net/wireless/ath/ath9k/Makefile            |    2 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   19 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   10 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  197 ++--
 drivers/net/wireless/ath/ath9k/debug.h             |   35 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c         |  269 +++++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    1 -
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    4 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |   40 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   22 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 -
 drivers/net/wireless/ath/carl9170/main.c           |   12 -
 drivers/net/wireless/ath/carl9170/rx.c             |    9 +-
 drivers/net/wireless/ath/main.c                    |    8 +
 drivers/net/wireless/ath/regd.c                    |    7 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |    2 +-
 drivers/net/wireless/b43/b43.h                     |    4 +-
 drivers/net/wireless/b43/main.c                    |   27 +-
 drivers/net/wireless/b43legacy/main.c              |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   40 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   21 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  339 +++---
 drivers/net/wireless/brcm80211/brcmfmac/nvram.c    |   94 ++
 drivers/net/wireless/brcm80211/brcmfmac/nvram.h    |   24 +
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  593 +++++-----
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |   31 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    4 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    1 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    1 -
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 -
 drivers/net/wireless/cw1200/main.c                 |    1 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    3 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    7 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    7 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    4 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   10 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   15 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |    3 -
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   28 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   13 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |    2 +
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   13 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    4 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    9 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    4 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   22 +
 drivers/net/wireless/libertas/cfg.c                |    7 +-
 drivers/net/wireless/mac80211_hwsim.c              | 1246 ++++++++++------=
----
 drivers/net/wireless/mac80211_hwsim.h              |   18 +
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   14 +
 drivers/net/wireless/mwifiex/fw.h                  |    2 +-
 drivers/net/wireless/mwifiex/scan.c                |    4 +-
 drivers/net/wireless/mwifiex/usb.c                 |   54 +-
 drivers/net/wireless/mwifiex/usb.h                 |   12 +-
 drivers/net/wireless/mwl8k.c                       |    2 -
 drivers/net/wireless/p54/main.c                    |    1 -
 drivers/net/wireless/p54/txrx.c                    |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    1 +
 drivers/net/wireless/ti/wl1251/main.c              |    1 -
 drivers/net/wireless/ti/wlcore/main.c              |   11 +-
 drivers/nfc/Kconfig                                |    1 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/mei_phy.c                              |    2 +-
 drivers/nfc/nfcmrvl/Kconfig                        |   23 +
 drivers/nfc/nfcmrvl/Makefile                       |    9 +
 drivers/nfc/nfcmrvl/main.c                         |  165 +++
 drivers/nfc/nfcmrvl/nfcmrvl.h                      |   48 +
 drivers/nfc/nfcmrvl/usb.c                          |  459 +++++++
 drivers/nfc/pn533.c                                |    3 +
 drivers/nfc/pn544/pn544.c                          |   48 +-
 drivers/nfc/port100.c                              |    1 +
 drivers/staging/winbond/wbusb.c                    |    1 -
 include/linux/ieee80211.h                          |    2 +
 include/net/cfg80211.h                             |    8 +
 include/net/mac80211.h                             |    8 +-
 include/net/nfc/digital.h                          |   10 +
 include/net/nfc/nci_core.h                         |    2 +
 include/net/regulatory.h                           |    4 +
 net/mac80211/cfg.c                                 |    3 +-
 net/mac80211/debugfs_netdev.c                      |   61 +-
 net/mac80211/ht.c                                  |    5 +-
 net/mac80211/ieee80211_i.h                         |    2 +
 net/mac80211/main.c                                |   22 +-
 net/mac80211/mesh.c                                |    1 +
 net/mac80211/mesh_plink.c                          |    1 +
 net/mac80211/rx.c                                  |   40 +-
 net/mac80211/sta_info.c                            |  238 ++--
 net/mac80211/trace.h                               |   27 +
 net/mac80211/tx.c                                  |    2 +
 net/mac80211/util.c                                |   41 +
 net/mac80211/wpa.c                                 |    2 +-
 net/nfc/core.c                                     |    7 +-
 net/nfc/digital_core.c                             |   28 +-
 net/nfc/digital_dep.c                              |   54 +-
 net/nfc/hci/core.c                                 |    7 +-
 net/nfc/llcp_commands.c                            |    6 +-
 net/nfc/llcp_core.c                                |    1 -
 net/nfc/llcp_sock.c                                |    1 -
 net/nfc/nci/core.c                                 |   27 +-
 net/wireless/nl80211.c                             |  111 +-
 net/wireless/reg.c                                 |    2 +
 net/wireless/scan.c                                |    7 +-
 net/wireless/sme.c                                 |   13 +-
 net/wireless/util.c                                |   15 +
 net/wireless/wext-compat.c                         |    6 +-
 129 files changed, 3808 insertions(+), 1794 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/debug_sta.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/nvram.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/nvram.h
 create mode 100644 drivers/nfc/nfcmrvl/Kconfig
 create mode 100644 drivers/nfc/nfcmrvl/Makefile
 create mode 100644 drivers/nfc/nfcmrvl/main.c
 create mode 100644 drivers/nfc/nfcmrvl/nfcmrvl.h
 create mode 100644 drivers/nfc/nfcmrvl/usb.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJS2YvcAAoJEJctW/TcYTgGP+4QAJiCpztw1Sm9OXIwrHHhpgwT
rgu/gWgIalbjG3alg5Q2jEafntMJLJ3erpTw2Nr1aH39v6R9QWodZSd8Zb4vox8q
jsSi9pCfuXe8/OtMimnNWeXDdF6oWP3Bb1yij3/O1I4eMXn+9yAYT3dUM32XcNUK
r6uB8qTdaN/JuDNs1LziJYlf0e6LsXXzDRXqfE0RrJHPSJTKlR1pugz2cXSbQYMi
rc2PasNqWbiOe3CZiagfPUama9WSROzz8bzybNayvT2Ah2GRttsyytC/6FruF2Te
Z+AwBhljolfZkrqNcDCJ9zBNowoQCUwNrxT0zeCEshOzBK33iWhgpC5NCr9vdCI5
HX5OMz2kUejShIZrhEIlI0HuUndFglq4+HqEvIwr7U9NBec6cfl17daBZmy1HdPy
StGOd9J3gjIh1xqz3pc/tT4cow3ZAs5I2vizGe1E9Qx8li973wYd/R83jWHi6Oca
6u0x8hIg4TpnOGfsEPPJIkQNpNjasiLdip5fx0CVx0PihosjNhMl8J2OlHksj/Gj
Q0S/NiswMoCAs4TV0phiOLK0YQtV5KkN6pslC5mZ6WTsLbolOxwjYbAKXIS4WqwB
pQLfYNnVREf+/Vz0/0AvJp/842nrdbDMxmN7Up3dNzd5LzDfsHGvxKBbUV+KXkXg
F3VGm/2IePiOhiwHYAv6
=qQ3k
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
