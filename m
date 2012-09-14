From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-09-14
Date: Fri, 14 Sep 2012 14:22:01 -0400
Message-ID: <20120914182200.GA7190@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 9316f0e3c6ba524d8fa14bfded048b252891931a

Dave,

This is another batch of updates intended for the 3.7 stream.

There are not a lot of large items, but iwlwifi, mwifiex, rt2x00,
ath9k, and brcmfmac all get some attention.  Wei Yongjun also provides
a series of small maintenance fixes.

This also includes a pull of the wireless tree in order to satisfy
some prerequisites for later patches.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 7f2e6a5d8608d0353b017a0fe15502307593734e:

  drivers/isdn/gigaset/common.c: Remove useless kfree (2012-09-13 17:05:17 =
-0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 9316f0e3c6ba524d8fa14bfded048b252891931a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-09-14 13:53:49 -0400)

----------------------------------------------------------------

Amitkumar Karwar (9):
      mwifiex: release semaphore acquired for internal scan operation
      mwifiex: don't disable wait_q_enabled flag
      mwifiex: remove get operation code for SUBSCRIBE EVENT command
      mwifiex: remove 11N_CFG command response handler
      mwifiex: remove AMSDU_AGGR_CTRL command response handler
      mwifiex: have same priority for AP and station traffic
      mwifiex: update adapter->bss_prio_tbl[j].bss_prio_cur correctly
      mwifiex: use country ie of requested AP while associating
      mwifiex: support custom world regulatory domain

Andi Kleen (1):
      brcm80211: Remove bogus memcpy in ai_detach

Andre Guedes (1):
      Bluetooth: Fix use-after-free bug in SMP

Andy Shevchenko (1):
      wireless: at76c50x: eliminate hex2str()

Arend van Spriel (3):
      wext: include wireless event id when it has a size problem
      brcmfmac: fix use of dev_kfree_skb() in irq context
      brcmfmac: add callback for nl80211 testmode command

Avinash Patil (2):
      mwifiex: parse rate info for AP
      mwifiex: separate TxPD processing routine for AP

Bing Zhao (3):
      mwifiex: make use of is_zero_ether_addr()
      mwifiex: do not hint regulatory domain with f/w country code
      mwifiex: disable WOW by default

Christian Lamparter (1):
      p54: fix off-by-one null pointer bug in p54_tx_80211

Daniel Drake (2):
      libertas sdio: fix suspend when interface is down
      libertas: set mac control synchronously during init

Daniel Golle (1):
      rt2x00: add MediaTek/RaLink Rt3352 WiSoC

David Spinadel (1):
      iwlwifi: remove radio_config from eeprom_data

Eliad Peller (1):
      mac80211: clear bssid on auth/assoc failure

Felix Fietkau (6):
      ath9k_hw: do not enable the MIB interrupt in the interrupt mask regis=
ter
      ath9k_hw: clear the AM2PM predistortion mask on AR933x
      ath9k_hw: calibrate PA input for PA predistortion
      ath9k_hw: disable PA linearization for AR9462
      ath9k: fix PA linearization calibration related crash
      ath9k_hw: enable PA linearization

Franky Lin (1):
      brcmfmac: add BCM43241 sdio interface driver support

Gertjan van Wingerde (6):
      rt2x00: Identify ASUS USB-N53 device.
      rt2x00: Fix word size of rt2500usb MAC_CSR19 register.
      rt2x00: Fix rfkill polling prior to interface start.
      rt2x00: Align GPIO register definitions with the datasheets.
      rt2x00: Unify GPIO register field namings
      rt2x00: rt2800 - Make probe_hw function common between PCI and USB.

Gustavo Padovan (1):
      Bluetooth: Use USB_VENDOR_AND_INTERFACE() for Broadcom devices

Hante Meuleman (13):
      brcmfmac: dont use ZERO flag for usb IN
      brcmfmac: fix race condition for rx and tx data.
      brcmfmac: fix get rssi by clearing getvar struct.
      brcmfmac: prevent possible race condition on usb rx control.
      brcmfmac: Add 43242 USB support.
      brcmfmac: Add 43143 USB support.
      brcmfmac: Stop all net if queues on tx flow halt.
      brcmfmac: Add extra data support to firmware event queueing.
      brcmfmac: Add tx flow control on net if queue for USB.
      brcmfmac: Clean up scan related code.
      brcmfmac: refill buffers on rx protocol error.
      brcmfmac: avoid using local usb data.
      brcmfmac: add e-scan support.

Henrik Rydberg (1):
      Bluetooth: Add support for Apple vendor-specific devices

Hila Gonen (1):
      cfg80211: fix indentation

Ilan Peer (1):
      mac80211: Do not check for valid hw_queues for P2P_DEVICE

Jeff Disher (1):
      mwifiex: store mwifiex_ds_misc_subsc_evt in mwifiex_private

Johannes Berg (5):
      iwlwifi: fix antenna bitmask
      mac80211: don't use kerneldoc for ieee80211_add_rx_radiotap_header
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next
      iwlwifi: report A-MPDU status
      iwlwifi: reduce overhead if tracing disabled

John W. Linville (6):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jussi Kivilinna (1):
      zd1211rw: enable support for MFP

LEO Airwarosu Yoichi Shinoda (1):
      mac80211: Various small fixes for cfg.c: mpath_set_pinfo()

Larry Finger (4):
      rtlwifi: rtl8192c: rtl8192de: Fix typo in cursta_connectctate
      rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192se: Remove sparse war=
nings
      rtlwifi: Update header file
      rtlwifi: Remove EXPERIMENTAL as pre-requisite for the drivers

Marc Kleine-Budde (1):
      rt2x00: fix voltage setting for RT3572/RT3592

Ming Lei (1):
      wireless: ath9k-htc: only load firmware in need

Mohammed Shafi Shajakhan (11):
      ath9k: Fix a crash in 2 WIRE btcoex chipsets
      ath9k_hw: small optimization
      ath9k_hw: Fix invalid MCI GPM index access/caching
      ath9k: Fix BTCOEX timer triggering comparision
      ath9k: Make use of ath_stop_ani wrapper
      ath9k: Remove an obselete function declaration
      ath9k: Cleanup add/change_interface callbacks
      ath9k_htc: minor cleanup in ath9k_htc_add_station
      ath9k_htc: Add a modparam to enable BTCOEX rather than default
      ath9k_htc: Cancel BTCOEX related work before disabling BTCOEX
      ath9k: Add Generic hardware timer interrupt in debugfs

Peter Senna Tschudin (2):
      drivers/net/wireless/rtlwifi/rtl8192de/phy.c: removes unnecessary sem=
icolon
      drivers/net/wireless/ath/ath9k/ar9003_mac.c: removes unnecessary semi=
colon

Rajkumar Manoharan (5):
      ath9k_hw: Read and apply thermometer settings from EEPROM
      ath9k_hw: Read and configure thermocal for AR9462
      ath9k_hw: Wait BT calibration to complete
      ath9k_hw: use peak detection for 5GHz
      ath9k_hw: add 8 points for 5G temp slop

Robert P. J. Day (1):
      cfg80211: add kerneldoc entry for "vht_cap"

Saul St. John (1):
      bcma: don't leak memory for PCIE, MIPS, GBIT cores

Sergei Poselenov (1):
      rt2800usb: Added rx packet length validity check

Stone Piao (1):
      mwifiex: fix skb length issue when send a command to firmware

Sujith Manoharan (11):
      ath9k: Fix TX filter usage
      ath9k_hw: Add version/revision macros for AR9565
      ath9k_hw: Add AR9565 initvals
      ath9k_hw: Add AR9565 HW support
      ath9k: Set correct max streams for AR9565
      ath9k_hw: Fix spur mitigation for AR9565
      ath9k_hw: Program correct PLL value for AR9565
      ath9k: Add PCI ID for AR9565
      ath9k_hw: Handle gentimer termination properly
      ath9k_hw: Rename antenna diversity macros
      ath9k: Choose correct LED pin for AR9565

Vinicius Costa Gomes (2):
      Bluetooth: Change signature of smp_conn_security()
      Bluetooth: Fix sending a HCI Authorization Request over LE links

Wei Yongjun (16):
      nl80211: fix possible memory leak nl80211_connect()
      cfg80211: use list_move_tail instead of list_del/list_add_tail
      ipw2100: use is_zero_ether_addr() and is_broadcast_ether_addr()
      ipw2200: use is_zero_ether_addr() and is_broadcast_ether_addr()
      orinoco: use is_zero_ether_addr() instead of memcmp()
      drivers/net: use is_zero_ether_addr() instead of memcmp()
      airo: use is_zero_ether_addr() and is_broadcast_ether_addr()
      mwifiex: use is_broadcast_ether_addr() instead of memcmp()
      mwifiex: use is_zero_ether_addr() instead of memcmp()
      wireless: use is_broadcast_ether_addr() instead of memcmp()
      wl3501_cs: use is_broadcast_ether_addr() instead of memcmp()
      wl18xx: remove duplicated include from main.c
      airo: remove duplicated include from airo.c
      rtlwifi: rtl8192de: remove pointless conditional before kfree_skb()
      rtlwifi: rtl8192c: remove pointless conditional before kfree_skb()
      rndis_wlan: remove pointless check from rndis_scan()

Yevgeniy Melnichuk (1):
      Bluetooth: Add support for Sony Vaio T-Series

 drivers/bcma/main.c                                |   10 +
 drivers/bluetooth/ath3k.c                          |    2 +
 drivers/bluetooth/btusb.c                          |   12 +-
 drivers/net/wireless/airo.c                        |    7 +-
 drivers/net/wireless/at76c50x-usb.c                |   54 +-
 drivers/net/wireless/ath/ath9k/ani.c               |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  121 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   57 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   15 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |    2 -
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |  105 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  131 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   75 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    2 +-
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   | 1233 ++++++++++++++++=
++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    3 +
 drivers/net/wireless/ath/ath9k/debug.h             |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    3 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   12 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   33 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |   11 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    5 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   14 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   56 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/link.c              |   18 +-
 drivers/net/wireless/ath/ath9k/main.c              |   59 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   21 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    1 +
 drivers/net/wireless/ath/ath9k/reg.h               |    9 +
 drivers/net/wireless/ath/ath9k/xmit.c              |    5 +-
 drivers/net/wireless/brcm80211/Kconfig             |    8 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   25 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    2 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    8 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   24 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   10 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |   17 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  237 ++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  598 +++++++++-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   25 +
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    3 -
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    1 +
 drivers/net/wireless/hostap/hostap_info.c          |    4 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |   15 +-
 drivers/net/wireless/hostap/hostap_main.c          |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |   11 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   11 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    3 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    1 +
 drivers/net/wireless/iwlwifi/dvm/rx.c              |   11 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   34 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    2 -
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   25 +-
 drivers/net/wireless/libertas/cmd.c                |   16 +
 drivers/net/wireless/libertas/cmd.h                |    1 +
 drivers/net/wireless/libertas/if_sdio.c            |    5 +
 drivers/net/wireless/libertas/main.c               |    4 +-
 drivers/net/wireless/mwifiex/11n.c                 |   38 -
 drivers/net/wireless/mwifiex/11n.h                 |    5 -
 drivers/net/wireless/mwifiex/cfg80211.c            |   51 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   15 +-
 drivers/net/wireless/mwifiex/fw.h                  |    8 +-
 drivers/net/wireless/mwifiex/init.c                |    6 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    7 +-
 drivers/net/wireless/mwifiex/main.c                |    1 -
 drivers/net/wireless/mwifiex/main.h                |    9 +-
 drivers/net/wireless/mwifiex/scan.c                |    4 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    3 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   38 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   40 +
 drivers/net/wireless/mwifiex/txrx.c                |    6 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   39 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   70 ++
 drivers/net/wireless/mwifiex/wmm.c                 |    9 +-
 drivers/net/wireless/orinoco/wext.c                |    7 +-
 drivers/net/wireless/p54/main.c                    |    3 +-
 drivers/net/wireless/rndis_wlan.c                  |    3 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |   18 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   52 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  330 +++++-
 drivers/net/wireless/rt2x00/rt2800lib.h            |   22 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   73 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   65 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   19 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |   27 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   11 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |   31 +-
 drivers/net/wireless/rtlwifi/Kconfig               |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   41 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    6 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    2 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  108 +-
 drivers/net/wireless/ti/wl18xx/main.c              |    1 -
 drivers/net/wireless/wl3501_cs.c                   |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |    3 +-
 include/net/bluetooth/smp.h                        |    2 +-
 include/net/cfg80211.h                             |    1 +
 net/bluetooth/hci_conn.c                           |    4 +
 net/bluetooth/l2cap_core.c                         |   11 +-
 net/bluetooth/l2cap_sock.c                         |    2 +-
 net/bluetooth/smp.c                                |   10 +-
 net/mac80211/cfg.c                                 |    9 +-
 net/mac80211/iface.c                               |   16 +-
 net/mac80211/mlme.c                                |    4 +
 net/mac80211/rx.c                                  |    2 +-
 net/wireless/nl80211.c                             |    4 +-
 net/wireless/reg.c                                 |    6 +-
 net/wireless/scan.c                                |    2 +-
 net/wireless/wext-core.c                           |    8 +-
 130 files changed, 3664 insertions(+), 918 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9565_1p0_initvals.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQU3XIAAoJEJctW/TcYTgGGwYP/jMHSTcQmC0PWcId2bCK5S7q
/wJK1Zu+L35RUBacguYdxDnl4WOKnRLTC8tn+08QX3OcuvbAzUXLcJ2IjJPt7ffU
URwBjaM3yvSu1u2D/q/Fews0TJVMMdXs46L57X+9qn8cim2ONtez8YqBPZrdVdLg
b0NotwEbr2Qlqe8V83/MFywmPg8QPtYsslC7QSU+P+HT8i8N6nN+uCv+e/fRahwY
cNw4a16ftOzkjAxkQWKXCEyj59nPoUSE9kDVyBijrp/kAFWzhQQmEw62qimQBYNG
3aquF84Npu9l/DjWaukoeI0cQcv+3Y/Aw36uOzcUMFbb0asCIwgXpHVQNqQrHAzh
3z2imePMTSXp+eG7VMzNYtZFjGryjndHX9Fj3HSpBu3MuxMDUZyplu+zz77eS60v
mwJyjZU/nLz3SG1DHFTtzMk04zRTdvXVPI9lsU/3i6lanX4c7JrGRxN4rJY6QL85
FvWqgRVssgUoUdfNy7h0OTGFt2o5qeNDAfMz8qPW5uO1gpufkhKPJ3yg226CRmRg
PiraP3CDaJNmiymH7uN+7LqV9d8xC5o7lmQCW2WZgu2RJnU+lxY3D1UtQ+Q0R5ia
+BI5o1fuprXyKPvPIaNoP0c9KN2VbChfHn8NpWZY1U7xEgI07Q/fQ8PicWe4cpGT
v5ENc5uRUD/RnivWiW6t
=PhqG
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
