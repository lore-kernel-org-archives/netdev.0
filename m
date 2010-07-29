From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-07-29
Date: Thu, 29 Jul 2010 15:12:46 -0400
Message-ID: <20100729191245.GF2424@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Yet another slew of changes intended for 2.6.36...

=46or the first time, this pull request includes a batch of bluetooth
stuff by way of Marcel.  Some upcoming developments are likely to
require more extensive integration between 802.11 and Bluetooth bits, s=
o
Marcel's tree will be feeding wireless-next-2.6 for a while.

The rest is the usual stuff from the usual suspects -- mostly driver
updates with the usual strong showings from ath9k and iwlwifi, this tim=
e
joined by libertas in particular.

This is a "for-davem" branch, so hopefully there will be no pain for yo=
u
to pull this time. :-)

Please let me know if there are problems!

John

---

The following changes since commit 7f3e01fee41a322747db2d7574516d9fbd37=
85c0:

  net: bnx2x_cmn.c needs net/ip6_checksum.h for csum_ipv6_magic (2010-0=
7-28 22:20:34 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (1):
      Bluetooth: Process interrupt in main thread of btmrvl driver as w=
ell

Christian Lamparter (1):
      cfg80211: fix dev <-> wiphy typo

Cyril Lacoux (1):
      Bluetooth: Added support for controller shipped with iMac i5

Dan Carpenter (6):
      ath9k: snprintf() returns largish values
      ath5k: snprintf() returns largish values
      mac80211: freeing the wrong variable
      wireless: remove unneeded variable from regulatory_hint_11d()
      libertas: precedence bug
      Bluetooth: Fix kfree() =3D> kfree_skb() in hci_ath.c

Dan Williams (16):
      libertas: clean up MONITOR_MODE command
      libertas: clean up RSSI command
      libertas: convert 11D_DOMAIN_INFO to a direct command
      libertas: remove unused indirect TPC_CFG command leftovers
      libertas: remove unused Automatic Frequency Control command
      libertas: remove Beacon Control
      libertas: convert LED_GPIO_CTRL to a direct command
      libertas: convert register access to direct commands
      libertas: convert Mesh Blinding Table access to a direct command
      libertas: convert CMD_FWT_ACCESS to a direct command
      libertas: remove unused indirect command response handler
      libertas: convert PS_MODE to a direct command
      libertas: convert DEEP_SLEEP timer to a direct command
      libertas: kill unused lbs_prepare_and_send_command()
      libertas: rename lbs_get_cmd_ctrl_node() to lbs_get_free_cmd_node=
()
      libertas: remove unused cmd_pending waitq

=46elix Fietkau (5):
      ath9k: fix yet another buffer leak in the tx aggregation code
      ath9k_hw: fix invalid extension channel noisefloor readings in HT=
20
      ath9k_hw: fix a small typo in the noisefloor calibration debug co=
de
      ath9k_hw: simplify noisefloor calibration chainmask calculation
      mac80211: inform drivers about the off-channel status on channel =
changes

Gustavo F. Padovan (44):
      Bluetooth: Remove max_tx and tx_window module paramenters from L2=
CAP
      Bluetooth: Remove L2CAP Extended Features from Kconfig
      Bluetooth: Fix drop of packets with invalid req_seq/tx_seq
      Bluetooth: Fix bug with ERTM vars increment
      Bluetooth: Only check SAR bits if frame is an I-frame
      Bluetooth: Fix bug in l2cap_ertm_send() behavior
      Bluetooth: Proper shutdown ERTM when closing the channel
      Bluetooth: Fix L2CAP control bit field corruption
      Bluetooth: Stop ack_timer if ERTM enters in Local Busy or SREJ_SE=
NT
      Bluetooth: Update buffer_seq before retransmit frames
      Bluetooth: Fix handle of received P-bit
      Bluetooth: Check the tx_window size on setsockopt
      Bluetooth: Check packet FCS earlier
      Bluetooth: Fix missing retransmission action with RR(P=3D1)
      Bluetooth: Fix ERTM error reporting to the userspace
      Bluetooth: Add debug output to ERTM code
      Bluetooth: Tweaks to l2cap_send_i_or_rr_or_rnr() flow
      Bluetooth: Change the way we set ERTM mode as mandatory
      Bluetooth: Disconnect the channel if we don't want the proposed m=
ode
      Bluetooth: Prefer Basic Mode on receipt of ConfigReq
      Bluetooth: Actively send request for Basic Mode
      Bluetooth: Refuse ConfigRsp with different mode
      Bluetooth: Remove check for supported mode
      Bluetooth: Disconnect early if mode is not supported
      Bluetooth: Don't accept ConfigReq if we aren't in the BT_CONFIG s=
tate
      Bluetooth: Remove the send_lock spinlock from ERTM
      Bluetooth: Add backlog queue to ERTM code
      Bluetooth: Improve ERTM local busy handling
      Bluetooth: Send ConfigReq after send a ConnectionRsp
      Bluetooth: Fix bug in kzalloc allocation size
      Bluetooth: Keep code under column 80
      Bluetooth: Add Copyright notice to L2CAP
      Bluetooth: Update L2CAP version information
      Bluetooth: Add Google's copyright to L2CAP
      Bluetooth: Move bit-field variable in USB driver to data->flags
      Bluetooth: Fix typo in hci_event.c
      Bluetooth: Enable L2CAP Extended features by default
      Bluetooth: Use __packed annotation
      Bluetooth: Use __packed annotation for drivers
      Bluetooth: Fix permission of hci_ath.c
      Bluetooth: Test 'count' value before enter the loop
      Bluetooth: Use hci_recv_stream_fragment() in UART driver
      Bluetooth: Add __init and __exit marks to UART drivers
      Bluetooth: Add __init and __exit marks to RFCOMM

Ivo van Doorn (1):
      rt2x00: Fix regression for rt2500pci

Joe Perches (5):
      Bluetooth: Remove unnecessary casts of private_data in drivers
      include/net/cfg80211.h: Add wiphy_<level> printk equivalents
      drivers/net/wireless: Use wiphy_<level>
      drivers/net/wireless/at76c50x-usb.c: Neaten macros
      wireless: Convert wiphy_debug macro to function

Johan Hedberg (4):
      Bluetooth: Add blacklist support for incoming connections
      Bluetooth: Add debugfs support for showing the blacklist
      Bluetooth: Add missing HCIUARTGETDEVICE ioctl to compat_ioctl.c
      Bluetooth: Add HCIUARTSETFLAGS and HCIUARTGETFLAGS ioctls

Johannes Berg (8):
      iwlagn: fix firmware loading TLV error path
      iwlwifi: make iwl_mac_beacon_update static
      iwlwifi: reduce beacon fill conditions
      iwlwifi: remove spurious semicolons
      mac80211: remove bogus rcu_read_lock()
      cfg80211: fix IBSS default management key
      mac80211: fix sta assignment
      mac80211: allow drivers to request DTIM period

John W. Linville (24):
      iwlagn: use __packed on new structure definitions
      wl1251: fix sparse-generated warnings
      rtl8180: improve signal reporting for actual rtl8180 hardware
      rtl8180: silence "dubious: x | !y" sparse warning
      MAINTAINERS: mark prism54 obsolete
      MAINTAINERS: orphan the raylink wireless driver
      MAINTAINERS: orphan the zd1201 wireless driver
      MAINTAINERS: remove entry for wavelan
      iwlwifi: assume vif is NULL for internal scans and non-NULL other=
wise
      minstrel_ht: remove unnecessary NULL check in minstrel_ht_update_=
caps
      minstrel: don't complain about feedback for unrequested rates
      lib80211: remove unused host_build_iv option
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-next-2.6
      p54: Added get_survey callback in order to get channel noise
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-next-2.6
      ath9k: enable serialize_regmode for non-PCIE AR9160
      mwl8k: add get_survey callback in order to get channel noise
      ar9170: add get_survey callback in order to get channel noise
      wl1251: add get_survey callback in order to get channel noise
      libertas_tf: add get_survey callback in order to get channel nois=
e
      wl1271: add get_survey callback in order to get channel noise
      wl1251: update hw/fw version info in wiphy struct
      wl1271: update hw/fw version info in wiphy struct
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (1):
      mac80211: Fix key freeing to handle unlinked keys

Jo=E3o Paulo Rechi Vita (8):
      Bluetooth: Fix SREJ_QUEUE corruption in L2CAP
      Bluetooth: Fix l2cap_sock_connect error return.
      Bluetooth: Make l2cap_streaming_send() void.
      Bluetooth: Fix error return value on sendmsg.
      Bluetooth: Fix error return value on sendmsg.
      Bluetooth: Fix error return for l2cap_connect_rsp().
      Bluetooth: Fix error value for wrong FCS.
      Bluetooth: Fix error return on L2CAP-HCI interface.

Julia Lawall (3):
      Bluetooth: Use kmemdup for drivers
      Bluetooth: Use kzalloc for drivers
      drivers/net/wireless/wl12xx: Use kmemdup

Justin P. Mattock (1):
      Bluetooth: Fix warning: variable 'tty' set but not used

Kulikov Vasiliy (1):
      Bluetooth: Silence warning in btmrvl SDIO driver

Lennert Buytenhek (1):
      mwl8k: change maintenance status

Luis R. Rodriguez (2):
      ath9k: remove the two wiphys scanning at the same time message
      Revert "mac80211: fix sw scan bracketing"

Marcel Holtmann (1):
      Bluetooth: Defer SCO setup if mode change is pending

Nathan Holstein (1):
      Bluetooth: Fix bug with ERTM minimum packet length

Ron Shaffer (2):
      Bluetooth: Remove extraneous white space
      Bluetooth: Reassigned copyright to Code Aurora Forum

Senthil Balasubramanian (4):
      ath9k: Introduce bit masks for valid and valid_single_stream.
      ath9k: Add three stream rate control support for AR938X.
      ath9k: Fix incorrect user ratekbs of MCS15 ShortGI
      ath9k: remove unused base_index from rate table.

Stanislaw Gruszka (4):
      rt2500usb: write keys to proper registers
      rt2500usb: truly disable encryption when initialize
      rt2500usb: disallow to set WEP key with non zero index
      iwlwifi: fix scan abort

Sujith (1):
      mac80211: Don't set per-BSS QoS for monitor interfaces

Suraj Sumangala (5):
      Bluetooth: Add one more buffer for HCI stream reassembly
      Bluetooth: Implement hci_reassembly helper to reassemble RX packe=
ts
      Bluetooth: Modified hci_recv_fragment() to use hci_reassembly hel=
per
      Bluetooth: Implemented HCI frame reassembly for RX from stream
      Bluetooth: Support for Atheros AR300x serial chip

Vasanthakumar Thiagarajan (1):
      ath9k: Fix inconsistency between txq->stopped and the actual queu=
e state

Wey-Yi Guy (6):
      iwlagn: add statistic notification structure for WiFi/BT devices
      iwlagn: add .cfg flag to idenfity the need for bt statistics
      iwlagn: Add support for bluetooth statistics notification
      iwlagn: add bluetooth stats to debugfs
      iwlwifi: add TLV to specify the size of phy calibration table
      iwlwifi: read multiple MAC addresses

Yuri Ershov (3):
      mac80211: Put some code under MESH macro
      nl80211: Fix memory leaks
      cfg80211: Update of regulatory request initiator handling

 MAINTAINERS                                    |   20 +-
 drivers/bluetooth/Kconfig                      |   12 +
 drivers/bluetooth/Makefile                     |    1 +
 drivers/bluetooth/bcm203x.c                    |    3 +-
 drivers/bluetooth/bpa10x.c                     |    2 +-
 drivers/bluetooth/btmrvl_debugfs.c             |    2 +-
 drivers/bluetooth/btmrvl_drv.h                 |    5 +-
 drivers/bluetooth/btmrvl_main.c                |    5 +-
 drivers/bluetooth/btmrvl_sdio.c                |  111 ++--
 drivers/bluetooth/btusb.c                      |   13 +-
 drivers/bluetooth/dtl1_cs.c                    |    2 +-
 drivers/bluetooth/hci_ath.c                    |  235 ++++++++
 drivers/bluetooth/hci_bcsp.c                   |    4 +-
 drivers/bluetooth/hci_h4.c                     |  107 +----
 drivers/bluetooth/hci_ldisc.c                  |   20 +-
 drivers/bluetooth/hci_ll.c                     |    6 +-
 drivers/bluetooth/hci_uart.h                   |   15 +-
 drivers/net/wireless/adm8211.c                 |   53 +-
 drivers/net/wireless/at76c50x-usb.c            |  168 +++---
 drivers/net/wireless/ath/ar9170/cmd.c          |    7 +-
 drivers/net/wireless/ath/ar9170/led.c          |    4 +-
 drivers/net/wireless/ath/ar9170/main.c         |  191 ++++---
 drivers/net/wireless/ath/ar9170/phy.c          |    8 +-
 drivers/net/wireless/ath/ath5k/debug.c         |   18 +
 drivers/net/wireless/ath/ath9k/ahb.c           |    7 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |    3 +
 drivers/net/wireless/ath/ath9k/ar9002_phy.c    |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h         |    2 +-
 drivers/net/wireless/ath/ath9k/calib.c         |   21 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |    9 +
 drivers/net/wireless/ath/ath9k/hw.c            |    3 +-
 drivers/net/wireless/ath/ath9k/main.c          |   13 +-
 drivers/net/wireless/ath/ath9k/pci.c           |    7 +-
 drivers/net/wireless/ath/ath9k/rc.c            |  601 ++++++++++++----=
----
 drivers/net/wireless/ath/ath9k/rc.h            |   89 +++-
 drivers/net/wireless/ath/ath9k/virtual.c       |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   20 +-
 drivers/net/wireless/ipw2x00/libipw.h          |    1 -
 drivers/net/wireless/ipw2x00/libipw_tx.c       |   16 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c        |    1 +
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c        |    3 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c        |    7 +
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c   |   64 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c |  225 ++++++--
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h |    7 +
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c      |  167 ++++--
 drivers/net/wireless/iwlwifi/iwl-agn.c         |  141 +++--
 drivers/net/wireless/iwlwifi/iwl-calib.h       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h    |   55 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c        |   65 +--
 drivers/net/wireless/iwlwifi/iwl-core.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c     |   13 +
 drivers/net/wireless/iwlwifi/iwl-dev.h         |   16 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h      |    1 +
 drivers/net/wireless/iwlwifi/iwl-scan.c        |   18 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   22 +-
 drivers/net/wireless/libertas/cfg.c            |  197 +------
 drivers/net/wireless/libertas/cfg.h            |    6 -
 drivers/net/wireless/libertas/cmd.c            |  718 ++++++++++------=
--------
 drivers/net/wireless/libertas/cmd.h            |   25 +-
 drivers/net/wireless/libertas/cmdresp.c        |  179 +------
 drivers/net/wireless/libertas/debugfs.c        |   67 +--
 drivers/net/wireless/libertas/decl.h           |    5 -
 drivers/net/wireless/libertas/defs.h           |   18 -
 drivers/net/wireless/libertas/dev.h            |    6 -
 drivers/net/wireless/libertas/host.h           |  142 ++---
 drivers/net/wireless/libertas/if_usb.c         |    4 +-
 drivers/net/wireless/libertas/main.c           |   35 +-
 drivers/net/wireless/libertas/mesh.c           |  216 ++++++--
 drivers/net/wireless/libertas/mesh.h           |   14 +-
 drivers/net/wireless/libertas/tx.c             |    2 +-
 drivers/net/wireless/libertas_tf/libertas_tf.h |    3 +
 drivers/net/wireless/libertas_tf/main.c        |   18 +
 drivers/net/wireless/mac80211_hwsim.c          |   99 ++--
 drivers/net/wireless/mwl8k.c                   |  154 +++---
 drivers/net/wireless/orinoco/cfg.c             |    5 +-
 drivers/net/wireless/p54/eeprom.c              |   76 ++--
 drivers/net/wireless/p54/fwio.c                |   53 +-
 drivers/net/wireless/p54/led.c                 |    8 +-
 drivers/net/wireless/p54/main.c                |   17 +
 drivers/net/wireless/p54/p54pci.c              |    3 +-
 drivers/net/wireless/p54/txrx.c                |   36 +-
 drivers/net/wireless/rt2x00/rt2500usb.c        |   11 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c        |   19 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |   35 +-
 drivers/net/wireless/rtl818x/rtl8180_grf5101.c |   12 +-
 drivers/net/wireless/rtl818x/rtl8180_max2820.c |   19 +-
 drivers/net/wireless/rtl818x/rtl8180_rtl8225.c |    5 +-
 drivers/net/wireless/rtl818x/rtl8180_sa2400.c  |   28 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |   11 +-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    8 +-
 drivers/net/wireless/rtl818x/rtl818x.h         |    1 +
 drivers/net/wireless/wl12xx/wl1251.h           |    3 +
 drivers/net/wireless/wl12xx/wl1251_boot.c      |    8 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.h       |   12 +-
 drivers/net/wireless/wl12xx/wl1251_main.c      |   22 +
 drivers/net/wireless/wl12xx/wl1251_rx.c        |    6 +
 drivers/net/wireless/wl12xx/wl1251_tx.c        |   10 +-
 drivers/net/wireless/wl12xx/wl1251_tx.h        |    8 +-
 drivers/net/wireless/wl12xx/wl1271.h           |    3 +
 drivers/net/wireless/wl12xx/wl1271_main.c      |   32 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c        |    7 +
 fs/compat_ioctl.c                              |    9 +-
 include/net/bluetooth/bluetooth.h              |    3 +-
 include/net/bluetooth/hci.h                    |  187 ++++---
 include/net/bluetooth/hci_core.h               |   30 +-
 include/net/bluetooth/l2cap.h                  |   34 +-
 include/net/bluetooth/rfcomm.h                 |   14 +-
 include/net/cfg80211.h                         |   65 +++-
 include/net/lib80211.h                         |    3 -
 include/net/mac80211.h                         |   12 +-
 net/bluetooth/Kconfig                          |   13 -
 net/bluetooth/hci_conn.c                       |   34 +-
 net/bluetooth/hci_core.c                       |  204 +++++--
 net/bluetooth/hci_event.c                      |   39 +-
 net/bluetooth/hci_sock.c                       |   90 +++
 net/bluetooth/hci_sysfs.c                      |   38 ++
 net/bluetooth/l2cap.c                          |  669 ++++++++++++++--=
-------
 net/bluetooth/rfcomm/sock.c                    |    2 +-
 net/bluetooth/rfcomm/tty.c                     |    4 +-
 net/mac80211/cfg.c                             |   13 +-
 net/mac80211/ieee80211_i.h                     |    1 +
 net/mac80211/key.c                             |   13 +-
 net/mac80211/key.h                             |    3 +-
 net/mac80211/main.c                            |    3 +
 net/mac80211/mlme.c                            |   32 +-
 net/mac80211/rc80211_minstrel.c                |    1 -
 net/mac80211/rc80211_minstrel_ht.c             |    4 +-
 net/mac80211/scan.c                            |    8 +-
 net/mac80211/sta_info.c                        |    2 +-
 net/mac80211/tx.c                              |   19 +-
 net/mac80211/util.c                            |    8 +-
 net/mac80211/work.c                            |   43 ++
 net/wireless/core.c                            |   49 ++
 net/wireless/ibss.c                            |    4 +-
 net/wireless/lib80211_crypt_ccmp.c             |    1 -
 net/wireless/lib80211_crypt_tkip.c             |    1 -
 net/wireless/lib80211_crypt_wep.c              |    1 -
 net/wireless/nl80211.c                         |    2 +
 net/wireless/reg.c                             |    8 +-
 145 files changed, 3858 insertions(+), 2826 deletions(-)
 create mode 100644 drivers/bluetooth/hci_ath.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-07-29.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
