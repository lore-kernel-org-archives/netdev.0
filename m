From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-01-05
Date: Thu, 5 Jan 2012 11:09:38 -0500
Message-ID: <20120105160938.GC10666@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 1032c736e81cdf490ae62f86da7efe67c3c3e61d

Dave,

Here is the last wireless "feature" pull request intended for 3.3.
Mostly minutia, but highlights include an NFC spec update and some
relicensing of regulatory code under the ISC license.

After consulation with Kalle, I have reverted the ath6kl USB bits that
were causing build problems.

Please let me know if there are problems!

John

P.S. Sorry about the "ssh://" URL -- git.kernel.org seems a bit slow
about syncing today...

---

The following changes since commit 117ff42fd43e92d24c6aa6f3e4f0f1e1edada140:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-01-04=
 21:35:43 -0500)

are available in the git repository at:

  ssh://ra.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git f=
or-davem

Christian Lamparter (1):
      carl9170: move checksum and txseq into subfunctions

Dan Carpenter (1):
      iwlegacy: off by one in iwl3945_hw_build_tx_cmd_rate()

Dave T=C3=A4ht (1):
      wireless: Treat IPv6 diffserv the same as IPv4 for 802.11e

Djalal Harouni (1):
      drivers/iwlwifi: use dma_zalloc_coherent() for DMA allocation

Dmitry Shmidt (1):
      wireless: Protect regdomain change by mutex

Eliad Peller (1):
      mac80211: always clear SDATA_STATE_OFFCHANNEL flag

Gertjan van Wingerde (5):
      rt2x00: Identify rt2800usb chipsets.
      rt2x00: Whitespace cleanup.
      rt2x00: Convert big if-statements to switch-statements.
      rt2x00: RT3593 is also applicable to USB.
      rt2x00: Change RF3853 to RF3053.

Helmut Schaa (2):
      mac80211: Remove superfluous ieee80211_rx_h_remove_qos_control
      rt2x00: Mark active channel's survey data as "in use"

Ilan Elias (3):
      NFC: Update names and structs to NCI spec 1.0 d22
      NFC: Handle error during NCI data exchange
      NFC: Export a new attribute nfcid1 in target info

Jakub Kici=C5=84ski (2):
      rt2800usb: Let rt2x00usb handle USB padding
      rt2x00usb: Zero USB padding before sending URB

John W. Linville (2):
      ath6kl: revert USB support
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Julia Lawall (1):
      net/rfkill/rfkill-gpio.c: introduce missing kfree

Larry Finger (2):
      b43legacy: Avoid packet losses in the dma worker code
      rt2800usb: Move ID out of unknown

Luis R. Rodriguez (8):
      ath9k_hw: fix sparse warnings on ar9003_rtt.c
      ath9k: fix tx queue sparse complaint
      ath5k: avoid sparse warnings on tracing
      ath9k_hw: fix sparse complaint on ar9003_switch_com_spdt_get()
      cfg80211: replace reg.c Nokia commit c4c32294
      cfg80211: replace reg.c Nokia commit 269ac5
      cfg80211: relicense reg.c reg.h and genregdb.awk to ISC
      ath9k: make ath_mci_duty_cycle static

Mohammed Shafi Shajakhan (5):
      mac80211: fix scan state machine
      mac80211: fix kernel panic in IBSS due to a regression
      mac80211: use RCU read locks for sta_info_get
      ath9k: tx queue enable is read only for EDMA chipsets
      mac80211: remove dead code

Rafa=C5=82 Mi=C5=82ecki (7):
      b43: N-PHY: move common TX/RX functions
      b43: N-PHY: fix success condition of running samples
      b43: N-PHY: get idle TSSI values
      b43: add lacking boardflags defines
      b43: N-PHY: update gain ctl workarounds
      b43: N-PHY: fix controling RF override
      b43: N-PHY: fix typo in TX power fix

Rajkumar Manoharan (1):
      ath9k_hw: increase tx status ring buffer size

Stanislav Yakovlev (1):
      ipw2x00: remove reset_port functionality

Stanislaw Gruszka (9):
      iwlegacy: remove iwl-sta.c
      iwlegacy: move some i/o helpers out of inline
      iwlegacy: 4965: toggle tx antenna inline
      iwlegacy: 4965: small tx_cmd build cleanup
      iwlegacy: 3945: get rid of hw_{set,get}_rate
      iwlegacy: 4965: remove one il4965_hdl_beacon
      iwlegacy: random 3945-rs.c cleanups
      iwlegacy: 3945: simplify calculations of retry limit
      iwlegacy: 3945: fix hw passive scan on radar channels

Yogesh Ashok Powar (3):
      mac80211: Call driver commands after drv_start in mac80211 restart co=
de
      mwl8k: Recover from firmware crash
      mwl8k: Changing the driver version to 0.13

 drivers/net/wireless/ath/ath5k/trace.h         |    5 +-
 drivers/net/wireless/ath/ath6kl/Kconfig        |   25 +-
 drivers/net/wireless/ath/ath6kl/Makefile       |   37 +-
 drivers/net/wireless/ath/ath6kl/bmi.c          |   10 +-
 drivers/net/wireless/ath/ath6kl/debug.h        |    1 -
 drivers/net/wireless/ath/ath6kl/hif.c          |    5 -
 drivers/net/wireless/ath/ath6kl/htc.c          |   10 +-
 drivers/net/wireless/ath/ath6kl/sdio.c         |    2 +-
 drivers/net/wireless/ath/ath6kl/usb.c          |  431 -------------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h    |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_rtt.c    |    1 +
 drivers/net/wireless/ath/ath9k/ath9k.h         |    2 +-
 drivers/net/wireless/ath/ath9k/beacon.c        |    7 +-
 drivers/net/wireless/ath/ath9k/hw.h            |    2 +-
 drivers/net/wireless/ath/ath9k/mci.c           |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |    3 +
 drivers/net/wireless/ath/carl9170/fw.c         |   97 ++--
 drivers/net/wireless/b43/b43.h                 |   11 +
 drivers/net/wireless/b43/phy_n.c               |  355 +++++++----
 drivers/net/wireless/b43/phy_n.h               |    6 +
 drivers/net/wireless/b43/tables_nphy.c         |  106 +++-
 drivers/net/wireless/b43legacy/b43legacy.h     |   20 +
 drivers/net/wireless/b43legacy/dma.c           |   65 +-
 drivers/net/wireless/b43legacy/dma.h           |    5 +-
 drivers/net/wireless/b43legacy/main.c          |   86 ++-
 drivers/net/wireless/ipw2x00/libipw.h          |    4 -
 drivers/net/wireless/ipw2x00/libipw_wx.c       |   25 -
 drivers/net/wireless/iwlegacy/3945-mac.c       |   11 +-
 drivers/net/wireless/iwlegacy/3945-rs.c        |   31 +-
 drivers/net/wireless/iwlegacy/3945.c           |   20 +-
 drivers/net/wireless/iwlegacy/3945.h           |   21 +-
 drivers/net/wireless/iwlegacy/4965-mac.c       |   71 +--
 drivers/net/wireless/iwlegacy/4965.c           |   19 -
 drivers/net/wireless/iwlegacy/4965.h           |    8 -
 drivers/net/wireless/iwlegacy/common.c         |  161 +++++
 drivers/net/wireless/iwlegacy/common.h         |  206 +------
 drivers/net/wireless/iwlegacy/iwl-sta.c        |  817 --------------------=
----
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c  |   10 +-
 drivers/net/wireless/mwl8k.c                   |  138 ++++-
 drivers/net/wireless/rt2x00/rt2800.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c        |   47 +-
 drivers/net/wireless/rt2x00/rt2800usb.c        |   65 +--
 drivers/net/wireless/rt2x00/rt2x00.h           |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c        |   16 +-
 include/linux/nfc.h                            |    2 +
 include/net/nfc/nci.h                          |   49 +-
 include/net/nfc/nci_core.h                     |    6 +-
 include/net/nfc/nfc.h                          |    3 +
 net/mac80211/ieee80211_i.h                     |    2 -
 net/mac80211/mlme.c                            |    2 +
 net/mac80211/offchannel.c                      |   21 +-
 net/mac80211/rx.c                              |   20 -
 net/mac80211/scan.c                            |    2 +-
 net/mac80211/sta_info.c                        |    5 +-
 net/mac80211/util.c                            |   19 +-
 net/nfc/nci/core.c                             |   22 +-
 net/nfc/nci/lib.c                              |    3 -
 net/nfc/nci/ntf.c                              |   50 ++-
 net/nfc/nci/rsp.c                              |   10 -
 net/nfc/netlink.c                              |    3 +
 net/rfkill/rfkill-gpio.c                       |    2 +-
 net/wireless/genregdb.awk                      |   13 +-
 net/wireless/reg.c                             |   40 +-
 net/wireless/reg.h                             |   15 +
 net/wireless/regdb.h                           |   16 +
 net/wireless/util.c                            |    6 +-
 68 files changed, 1178 insertions(+), 2113 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath6kl/usb.c
 delete mode 100644 drivers/net/wireless/iwlegacy/iwl-sta.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPBctCAAoJEJctW/TcYTgGP94P/2FW2tix65QV1f4i1FwjNQYD
1xsLLoDanO+inKOZ7eQUQ717/hXoM57SE9C2KUoZnUQEqO/IPJ+fBtJe9+nPHsCe
ALfug+LVgUQCbG+kQOyrBm9qaYsd/3sx+ajOmTLiGTdIblLb2GrNfwDx4b+itQRV
iKF8U9Q00G9JplWcPKIp+JFks9R9Ej/STgukBE8T1wSl+vKkQl3BwoxxphAxgKBH
2ZUX95mtOIIzeSs+jPGU3RwaVhMJVDDrLKP9YYnVVPwweYywP4kQoZD9vE0XGSKX
TjEwSay72KbwThhXs2XMn0FquFuO6EVVHJco1cI0mOKrT2o9s4R9AXt9ZkfVEc+S
ON1LB2SJZcE26MNJoSW3jKRBiwqzTeLjgyFtsEe7hX1jnnNUoTjjOFtEbW2Y2Aa1
YUNsNEVlE4z1RaFPLS72XpuXuGuNn9NZQNGc0JcDUgusAV0mYz5PgKYE0krYrOcq
9Uvv/n6j0tiR5EjxHg1bhpTciFieWfEzAWFlPJzEhxclebDxoOs63Tgm67u6G0J4
oGdRMgegqolzAb9X3LQIg2j/jjhIlNMPs9plxgt2QSB100RKqg/4/00dpxff6OPv
OA5ARJg4Rv33OwE7GdQhwn+WOlc8VZfRPwUvFEsCV3vpQWSVVOepF7z0qVt1s6GP
EsDZ9A3RAsSQ5o3gHoxW
=UQNn
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
