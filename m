From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-06-28
Date: Fri, 28 Jun 2013 13:40:00 -0400
Message-ID: <20130628174000.GC30328@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Yet one more pull request for wireless updates intended for 3.11...

For the mac80211 bits, Johannes says:

"Here we have a few memory leak fixes related to BSS struct handling
mostly from Ben, including a fix for a more theoretical problem
(associating while a BSS struct times out) from myself, a compilation
warning fix from Arend, mesh fixes from Thomas, tracking the beacon
bitrate (Alex), a bandwidth change event fix (Ilan) and some initial
work for 5/10 MHz channels from Simon."

Regarding the iwlwifi bits, Johannes says:

"Emmanuel removed some unneeded/unsupported module parameters and adds a
Bluetooth 1x1 lookup-table for some upcoming products. From Alex I have
an older patch to add low-power receive support, this depended on a
mac80211 commit that only just came in with the merge from wireless-next
I did. Ilan made beacon timings better, and Eytan added some debug
statements for thermal throttling. I have a few cleanups, a fix for a
long-standing but rare warning, and, arguably the most important patch
here, the firmware API version bump for the 7260/3160 devices."

Also included is a Bluetooth pull -- Gustavo says:

"Here goes a set of patches to 3.11. The biggest work here is from Andre Gu=
edes
on the move of the Discovery to use the new request framework. Other than t=
hat
Johan provided a bunch of fixes to the L2CAP code. The rest are just small
fixes and clean ups."

On top of all that, there are a variety of updates and fixes to
brcmfmac, rt2x00, wil6210, ath9k, ath10k, and a few others here and
there.  This also includes a pull of the wireless tree, in order to
prevent some merge conflicts.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5e6700b3bf98fe98d630bf9c939ad4c85ce95592:

  sit: add support of x-netns (2013-06-27 22:30:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 57ed5cd695d7373b8ae0ae9f10fe945e774d58f0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-06-28 13:18:21 -0400)

----------------------------------------------------------------

Alexander Bondar (2):
      mac80211: track AP's beacon rate and give it to the driver
      iwlwifi: mvm: Add support for Low Power RX

Andre Guedes (14):
      Bluetooth: Make inquiry_cache_flush non-static
      Bluetooth: Update start_discovery to use HCI request
      Bluetooth: Remove start discovery handling from hci_event.c
      Bluetooth: Make mgmt_start_discovery_failed static
      Bluetooth: Move discovery macros to hci_core.h
      Bluetooth: Use HCI request in interleaved discovery
      Bluetooth: Update stop_discovery to use HCI request
      Bluetooth: Remove stop discovery handling from hci_event.c
      Bluetooth: Make mgmt_stop_discovery_failed static
      Bluetooth: Refactor hci_cc_le_set_scan_enable
      Bluetooth: Remove LE scan helpers
      Bluetooth: Remove inquiry helpers
      Bluetooth: Remove empty event handler
      Bluetooth: Mgmt Device Found Event

Andrei Emeltchenko (2):
      Bluetooth: Use HCI_MGMT instead of HCI_LINK_KEYS flag
      Bluetooth: Remove unneeded flag

Antonio Quartulli (1):
      Revert "mac80211: in IBSS use the Auth frame to trigger STA reinserti=
on"

Arend van Spriel (7):
      cfg80211: fix compilation warning for cfg80211_leave_all()
      brcmfmac: simplify transmit path
      brcmfmac: remove (ab)use of NL80211_NUM_ACS
      brcmfmac: tag packet in the netdev transmit callback
      brcmfmac: cleanup debug messages in brcmf_fws_hdrpush()
      brcmfmac: reduce firmware-signalling locking scope in rx path
      brcmfmac: remove code and comment for older kernel support

Ben Greear (6):
      mac80211: Ensure tid_start_tx is protected by sta->lock
      wireless: Make sure __cfg80211_connect_result always puts bss
      wireless: add comments about bss refcounting
      wireless: check for dangling wdev->current_bss pointer
      ath9k_htc: Support reporting tx and rx chain mask.
      ath9k_htc: Add ethtool stats support.

Chen Gang (1):
      Bluetooth: hidp: using strlcpy instead of strncpy, also beautify code.

Dan Carpenter (1):
      ipw2x00: printing the wrong array in debug code

Emmanuel Grumbach (4):
      iwlwifi: remove bt_ch_announce module param
      iwlwifi: remove plcp_check module parameter
      iwlwifi: remove auto_agg module parameter
      iwlwifi: mvm: add BT-Coex LUT for 1x1 products

Felix Fietkau (2):
      ath9k: fix an RCU issue in calling ieee80211_get_tx_rates
      ath9k: fix queue depth accounting in ath_tx_txqaddbuf

Franky Lin (3):
      brcmfmac: remove SDIO_REQ_ASYNC flag
      brcmfmac: use unified dongle address preparation function
      brcmfmac: add broken scatter-gather DMA support

Gabor Juhos (7):
      rt2x00: read 5GHz TX power values from the correct offset
      rt2x00: rt2800pci: don't use TXWI_DESC_SIZE directly
      rt2x00: rt2800: unify [RT]XWI_SIZE defines
      rt2x00: rt2800: increase EEPROM_SIZE to 512 bytes
      rt2x00: rt2800lib: turn on secondary PAs/LNAs for 3T/3R devices
      rt2x00: rt2800lib: turn on tertiary PAs/LNAs for 3T/3R devices
      rt2x00: rt2800lib: fix default TX power check for RT55xx

Gustavo Padovan (1):
      Bluetooth: Improve comments on the HCI_Delete_Store_Link_Key issue

Ilan Peer (2):
      mac80211: Fix VHT bandwidth change event
      iwlwifi: mvm: Change the settings of AP beacon time

Jaganath Kanakkassery (1):
      Bluetooth: Fix invalid length check in l2cap_information_rsp()

Johan Hedberg (12):
      Bluetooth: Handle LE L2CAP signalling in its own function
      Bluetooth: Rename L2CAP_CID_LE_DATA to L2CAP_CID_ATT
      Bluetooth: Fix LE vs BR/EDR selection when connecting
      Bluetooth: Fix EBUSY condition test in l2cap_chan_connect
      Bluetooth: Fix hardcoding ATT CID in __l2cap_chan_add()
      Bluetooth: Add clarifying comment to l2cap_conn_ready()
      Bluetooth: Fix duplicate call to l2cap_chan_ready()
      Bluetooth: Remove useless sk variable in l2cap_le_conn_ready
      Bluetooth: Remove unnecessary L2CAP channel state check
      Bluetooth: Simplify hci_conn_hold/drop logic for L2CAP
      Bluetooth: Remove useless hci_conn disc_timeout setting
      Bluetooth: Fix multiple LE socket handling

Johannes Berg (12):
      mac80211: fix TX aggregation TID struct leak
      iwlwifi: bump required firmware API version for 3160/7260
      iwlwifi: mvm: allow firmware crashes to wake system for debug
      iwlwifi: remove testmode
      Merge remote-tracking branch 'mac80211/master' into HEAD
      nl80211: use small state buffer for wiphy_dump
      cfg80211: require passing BSS struct back to cfg80211_assoc_timeout
      cfg80211: hold BSS over association process
      iwlwifi: pcie: rework RX buffer list init and freeing
      iwlwifi: always use 'rxq' as RX queue struct name
      iwlwifi: always use 'trans_pcie' name
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next

John W. Linville (7):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      ath10k: minimally handle new channel width enumeration values
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kirshenbaum Erez (2):
      wil6210: set vring index for all descriptors
      wil6210: add HW write-back option in TX descriptor

Larry Finger (1):
      rtlwifi: rtl8723ae: Fix typo in firmware names

Michal Kazior (3):
      ath10k: fix MSI-X setup failpath
      ath10k: fix 5ghz channel definitions
      ath10k: leave MMIC generation to the HW

Rafa=C5=82 Mi=C5=82ecki (2):
      b43: replace B43_BCMA_EXTRA with modparam allhwsupport
      bcma: add support for BCM43142

Shuah Khan (1):
      Bluetooth: Add missing reset_resume dev_pm_ops

Simon Wunderlich (5):
      nl80211: use attributes to parse beacons
      nl80211/cfg80211: add 5 and 10 MHz defines and wiphy flag
      nl80211: add rate flags for 5/10 Mhz channels
      mac80211: fix various components for the new 5 and 10 MHz widths
      mac80211: change IBSS channel state to chandef

Solomon Peachy (1):
      cw1200: Fix up a large pile of sparse warnings

Sujith Manoharan (7):
      ath9k_htc: Handle IDLE state transition properly
      ath9k: Enable WoW only for supported models
      ath9k: Add version macros for AR9462 2.1
      ath9k: Add initvals for AR9462 2.1
      ath9k: Program initvals for AR9462 2.1
      ath9k: Add support for AR9462 2.1
      ath9k: Add mix tx gain table for AR9462 2.0

Thomas Pedersen (4):
      mac80211: update mesh beacon on workqueue
      mac80211: allow self-protected frame tx without sta
      mac80211: initialize power mode for mesh STAs
      ath9k_htc: ifdef out IFTYPE_MESH advertisement

Wei Yongjun (1):
      ipw2200: fix error return code in ipw_load()

eytan lifshitz (1):
      iwlwifi: mvm: add thermal throttling debugging

 drivers/bcma/bcma_private.h                        |    2 +
 drivers/bcma/driver_chipcommon.c                   |   11 +-
 drivers/bcma/driver_chipcommon_pmu.c               |  123 ++
 drivers/bcma/host_pci.c                            |    1 +
 drivers/bcma/main.c                                |   19 +
 drivers/bcma/sprom.c                               |    1 +
 drivers/bluetooth/btusb.c                          |    1 +
 drivers/net/wireless/ath/ath10k/mac.c              |   53 +-
 drivers/net/wireless/ath/ath10k/pci.c              |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   62 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    4 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   63 +
 .../net/wireless/ath/ath9k/ar9462_2p1_initvals.h   | 1774 ++++++++++++++++=
++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    8 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   16 +
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |   97 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   13 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   46 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 +
 drivers/net/wireless/ath/ath9k/pci.c               |   57 +
 drivers/net/wireless/ath/ath9k/reg.h               |   13 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   16 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   12 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |    4 +
 drivers/net/wireless/b43/Kconfig                   |    6 -
 drivers/net/wireless/b43/main.c                    |   12 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  165 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   29 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  260 ++-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    5 -
 drivers/net/wireless/cw1200/cw1200.h               |    2 +-
 drivers/net/wireless/cw1200/cw1200_spi.c           |   32 +-
 drivers/net/wireless/cw1200/hwio.c                 |   18 +-
 drivers/net/wireless/cw1200/hwio.h                 |   31 +-
 drivers/net/wireless/cw1200/main.c                 |    4 +-
 drivers/net/wireless/cw1200/queue.c                |    2 +-
 drivers/net/wireless/cw1200/sta.c                  |   23 +-
 drivers/net/wireless/cw1200/txrx.c                 |    9 +-
 drivers/net/wireless/cw1200/wsm.c                  |   33 +-
 drivers/net/wireless/cw1200/wsm.h                  |   45 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    1 +
 drivers/net/wireless/ipw2x00/libipw_rx.c           |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   10 -
 drivers/net/wireless/iwlwifi/Makefile              |    1 -
 drivers/net/wireless/iwlwifi/dvm/Makefile          |    1 -
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   37 -
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   13 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    6 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    2 -
 drivers/net/wireless/iwlwifi/dvm/main.c            |   15 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   43 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |   40 +-
 drivers/net/wireless/iwlwifi/dvm/testmode.c        |  471 ------
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   12 -
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   16 -
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    6 -
 drivers/net/wireless/iwlwifi/iwl-test.c            |  852 ----------
 drivers/net/wireless/iwlwifi/iwl-test.h            |  161 --
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |  309 ----
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    2 -
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |   21 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    6 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   27 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    5 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   56 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |    8 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   22 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   30 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   22 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   71 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   17 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   12 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   53 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |    8 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    3 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |    3 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |    6 +-
 include/linux/bcma/bcma.h                          |    1 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   55 +
 include/linux/platform_data/brcmfmac-sdio.h        |    5 +
 include/net/bluetooth/hci.h                        |    1 -
 include/net/bluetooth/hci_core.h                   |   29 +-
 include/net/bluetooth/l2cap.h                      |    2 +-
 include/net/cfg80211.h                             |   46 +-
 include/net/mac80211.h                             |    2 +
 include/uapi/linux/nl80211.h                       |    4 +
 net/bluetooth/hci_core.c                           |  192 +--
 net/bluetooth/hci_event.c                          |   71 +-
 net/bluetooth/hidp/core.c                          |   14 +-
 net/bluetooth/l2cap_core.c                         |  123 +-
 net/bluetooth/l2cap_sock.c                         |    4 +-
 net/bluetooth/mgmt.c                               |  229 ++-
 net/mac80211/cfg.c                                 |   14 +-
 net/mac80211/ht.c                                  |    4 +-
 net/mac80211/ibss.c                                |   65 +-
 net/mac80211/ieee80211_i.h                         |    6 +-
 net/mac80211/mesh.c                                |   57 +-
 net/mac80211/mesh.h                                |    2 +
 net/mac80211/mesh_plink.c                          |    8 +-
 net/mac80211/mlme.c                                |   35 +-
 net/mac80211/rate.c                                |    8 +-
 net/mac80211/scan.c                                |    9 +
 net/mac80211/sta_info.c                            |    2 +
 net/mac80211/sta_info.h                            |    1 +
 net/mac80211/vht.c                                 |    2 +-
 net/wireless/chan.c                                |   57 +-
 net/wireless/core.c                                |    6 +
 net/wireless/mlme.c                                |   12 +-
 net/wireless/nl80211.c                             |  287 ++--
 net/wireless/scan.c                                |    4 +
 net/wireless/sme.c                                 |   23 +-
 net/wireless/sysfs.c                               |    2 +-
 119 files changed, 3772 insertions(+), 3098 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9462_2p1_initvals.h
 delete mode 100644 drivers/net/wireless/iwlwifi/dvm/testmode.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-test.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-test.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-testmode.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRzcpwAAoJEJctW/TcYTgGWgoP/0RoEP4JMx0uCULMX+YFA1t9
OXjeYeaeTh9L41n92aIaBM3nUhOV5o/u9FFLEUki9Tbqc+HA2NCHmiT64C2+TLvv
6V38LU9AptcadT+RpFJXzN+F5s6+WCg97BDCcaEeS+WYph+1q0Y1x8YMoaBThbiK
tVs97eF6nl9t9/6gwbffsIjKlnuMTg73laao3JUDf8s8Ou3D8Ov3Ho9VH4Ys/oFT
Wtjd0toiot9XkWhoSKRJBoSwf1GLgYvs8YXzvKXS7A8SQrelvGZB0j+tYKMr9N1D
5eOSMI3/2Tduzs2vVPO3f21/vdforVdGHijGpW3ahBWshpChlozrwKNuZSehCnww
GQhoJBgr/Gd1UuXxI1qqoIiQCzlWYv1ltfXy4iawX+mYikb3N+gU3E9ELAkcZDXU
xMxKWVoToiH8UvTo9DLImZMd5Ccg/FgU8GpQyNoB02SH6oLb+AyNE0OhSGhs9gLj
bw/F/2oHKRmG6L6jZ50hrsoNBKWRAGx4yk0PxkTh+w2jUw+d7aBUbpTt5Jcd6c+z
H7eGdoZgneX6C9gX5Ag6+1co11wRXiXKycTvhfMVX8ijIpSjTmNKAmeRUoMOe747
eOptUlL9hYvVthJbY0PEwfHpB0P1+1Z57QsunMsBJkUrMy4gUWwuly9IhVuZJyPO
ULo/vCgRvQ/1b7jV0Qz5
=4lgZ
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
