From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-10-17
Date: Thu, 17 Oct 2013 14:23:40 -0400
Message-ID: <20131017182339.GC1812@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57661 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227Ab3JQSaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 14:30:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a batch of updates intended for the 3.13 stream...

The biggest item of interest in here is wcn36xx, the new mac80211
driver for Qualcomm WCN3660/WCN3680 hardware.

Regarding the mac80211 bits, Johannes says:

"We have an assortment of cleanups and new features, of which the
biggest one is probably the channel-switch support in IBSS. Nothing
else really stands out much."

On top of that, the ath9k and rt2x00 get a lot of update action from
Felix Fietkau and Gabor Juhos, respectively.  There are a handful of
updates to other drivers here and there as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ccdbb6e96beca362db876d820ac1e560ff6d9579:

  tcp: tcp_transmit_skb() optimizations (2013-10-11 17:48:18 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 9f96da4dd2ccf685b506a21104cb13b1aadd907a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-10-17 14:02:07 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: use alloc_workqueue() function

Arik Nemtsov (1):
      mac80211: implement STA CSA for drivers using channel contexts

Eliad Peller (2):
      mac80211: fix some snprintf misuses
      ieee80211: fix vht cap definitions

Eugene Krasnikov (1):
      wcn36xx: mac80211 driver for Qualcomm WCN3660/WCN3680 hardware

Felipe Balbi (1):
      net: wireless: wl1251: update firmware path

Felix Fietkau (10):
      ath9k: use a separate data structure for rx buffers
      ath9k_hw: remove direct accesses to channel mode flags
      ath9k_hw: remove IS_CHAN_B()
      ath9k_hw: remove IS_CHAN_OFDM()
      ath9k_hw: simplify channel flags
      ath9k: make ath9k_cmn_update_ichannel static
      ath9k: move channel change code to ath_set_channel
      ath9k: remove sc->config.cabqReadyTime
      ath9k: make ath9k_uses_beacons static
      ath9k_hw: remove references to hw->conf

Fengguang Wu (1):
      wcn36xx: fix coccinelle warnings

Fred Zhou (2):
      mac80211: use exact-size allocation for authentication frame
      mac80211: improve default WMM parameter setting

Gabor Juhos (14):
      rt2x00: rt2800lib: remove TXMIXER_GAIN entries from the extended EEPR=
OM map
      rt2x00: rt2800lib: remove TXPOWER_DELTA entry from extended EEPROM map
      rt2x00: rt2800lib: fix default VGC values for RT3593
      rt2x00: rt2800lib: fix VGC programming for RT3572 and RT3593
      rt2x00: rt2800lib: fix default VGC values for RT3572 for the 5GHz band
      rt2x00: use generic EWMA functions for average RSSI calculations
      rt2x00: rt2800lib: fix VGC adjustment for RT5592
      rt2x00: rt2800lib: fix VGC adjustment for RT3572 and RT3593
      rt2x00: cleanup indentation in rt2800.h
      rt2x00: add rt2x00_has_cap_* helpers
      rt2x00: rt2x00lib: use rt2x00_has_cap_* helpers
      rt2x00: rt2800lib: use rt2x00_has_cap_* helpers
      rt2x00: rt61pci: use rt2x00_has_cap_* helpers
      rt2x00: rt73usb: use rt2x00_has_cap_* helpers

Hauke Mehrtens (3):
      bcma: reject PCI cards in bcma.
      bcma: add PCI id 0x4313
      brcmsmac: add support for a BCM4313 with PCI id 0x4313

Janusz Dziedzic (1):
      cfg80211: parse dfs region for internal regdb option

Johannes Berg (4):
      mac80211: add ieee80211_iterate_active_interfaces_rtnl()
      mac80211: use ERR_CAST()
      mac80211: add explicit IBSS driver operations
      regulatory: enable channels 52-64 and 100-144 for world roaming

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kevin Lo (3):
      rt2x00: rt2800lib: no need to toggle RF R30 bit 7 twice
      rt2x00: rt2800lib: fix RF registers for RT5390/RT5392
      rt2x00: rt2800lib: remove duplicate rf_vals for RF3053

Kirill Tkhai (1):
      rt2x00_pci: Fix interrupt handler name (visible at /proc/interrupts)

Lorenzo Bianconi (2):
      mac80211: add fixed_rate management to minstrel rc
      mac80211: do not override fixed_rate_idx in minstrel_ht_update_stats

Michael Opdenacker (1):
      net: p54spi: remove deprecated IRQF_DISABLED

Michal Kazior (1):
      mac80211: support reporting A-MSDU subframes individually

Peter Senna Tschudin (1):
      mwifiex: Change variable type to bool

Sergey Ryazanov (1):
      mac80211: Remove superfluous is_multicast_ether_addr() call

Simon Wunderlich (7):
      cfg80211: export cfg80211_chandef_dfs_required
      mac80211: split off channel switch parsing function
      mac80211: split off ibss disconnect
      mac80211: add support for CSA in IBSS mode
      mac80211: send a CSA action frame when changing channel
      nl80211: enable IBSS support for channel switch announcements
      nl80211: allow CAC only if no operation is going on

Stanislaw Gruszka (2):
      mac80211: change beacon/connection polling
      rt2x00: do not pause queue on flush

cedric Voncken (1):
      cfg80211: vlan priority handling in WMM

 MAINTAINERS                                    |    8 +
 drivers/bcma/host_pci.c                        |    8 +-
 drivers/net/wireless/ath/Kconfig               |    1 +
 drivers/net/wireless/ath/Makefile              |    1 +
 drivers/net/wireless/ath/ath9k/ani.c           |    6 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c    |   43 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |    7 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c     |   26 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |  113 +-
 drivers/net/wireless/ath/ath9k/ath9k.h         |   12 +-
 drivers/net/wireless/ath/ath9k/calib.c         |    9 +-
 drivers/net/wireless/ath/ath9k/common.c        |   91 +-
 drivers/net/wireless/ath/ath9k/common.h        |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |   32 +-
 drivers/net/wireless/ath/ath9k/hw.c            |   67 +-
 drivers/net/wireless/ath/ath9k/hw.h            |   82 +-
 drivers/net/wireless/ath/ath9k/init.c          |   87 +-
 drivers/net/wireless/ath/ath9k/mac.c           |    6 +-
 drivers/net/wireless/ath/ath9k/mac.h           |    2 -
 drivers/net/wireless/ath/ath9k/main.c          |  157 +-
 drivers/net/wireless/ath/ath9k/mci.c           |    8 +-
 drivers/net/wireless/ath/ath9k/recv.c          |   48 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   12 +-
 drivers/net/wireless/ath/wcn36xx/Kconfig       |   16 +
 drivers/net/wireless/ath/wcn36xx/Makefile      |    7 +
 drivers/net/wireless/ath/wcn36xx/debug.c       |  181 +
 drivers/net/wireless/ath/wcn36xx/debug.h       |   49 +
 drivers/net/wireless/ath/wcn36xx/dxe.c         |  805 ++++
 drivers/net/wireless/ath/wcn36xx/dxe.h         |  284 ++
 drivers/net/wireless/ath/wcn36xx/hal.h         | 4657 ++++++++++++++++++++=
++++
 drivers/net/wireless/ath/wcn36xx/main.c        | 1036 ++++++
 drivers/net/wireless/ath/wcn36xx/pmc.c         |   62 +
 drivers/net/wireless/ath/wcn36xx/pmc.h         |   33 +
 drivers/net/wireless/ath/wcn36xx/smd.c         | 2126 +++++++++++
 drivers/net/wireless/ath/wcn36xx/smd.h         |  127 +
 drivers/net/wireless/ath/wcn36xx/txrx.c        |  284 ++
 drivers/net/wireless/ath/wcn36xx/txrx.h        |  160 +
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h     |  238 ++
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    2 +-
 drivers/net/wireless/mwifiex/cmdevt.c          |    2 +-
 drivers/net/wireless/mwifiex/join.c            |    2 +-
 drivers/net/wireless/mwifiex/main.c            |    4 +-
 drivers/net/wireless/mwifiex/sta_cmd.c         |    2 +-
 drivers/net/wireless/mwifiex/wmm.c             |    2 +-
 drivers/net/wireless/p54/p54spi.c              |    2 +-
 drivers/net/wireless/rt2x00/Kconfig            |    1 +
 drivers/net/wireless/rt2x00/rt2800.h           |   42 +-
 drivers/net/wireless/rt2x00/rt2800lib.c        |  173 +-
 drivers/net/wireless/rt2x00/rt2x00.h           |  103 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c        |    8 +-
 drivers/net/wireless/rt2x00/rt2x00link.c       |   74 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c        |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c      |   39 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c        |    2 +
 drivers/net/wireless/rt2x00/rt61pci.c          |   20 +-
 drivers/net/wireless/rt2x00/rt73usb.c          |   18 +-
 drivers/net/wireless/ti/wl1251/wl1251.h        |    4 +-
 include/linux/ieee80211.h                      |    4 +-
 include/net/cfg80211.h                         |    9 +
 include/net/mac80211.h                         |   42 +
 net/mac80211/cfg.c                             |   92 +-
 net/mac80211/chan.c                            |    5 -
 net/mac80211/debugfs.c                         |   55 +-
 net/mac80211/driver-ops.h                      |   27 +
 net/mac80211/ibss.c                            |  608 +++-
 net/mac80211/ieee80211_i.h                     |   30 +-
 net/mac80211/iface.c                           |    4 +
 net/mac80211/key.c                             |    2 +-
 net/mac80211/mlme.c                            |  334 +-
 net/mac80211/rc80211_minstrel.c                |   14 +
 net/mac80211/rc80211_minstrel_ht.c             |   23 +-
 net/mac80211/rc80211_pid_debugfs.c             |   26 +-
 net/mac80211/rx.c                              |   39 +-
 net/mac80211/scan.c                            |    3 +-
 net/mac80211/spectmgmt.c                       |  162 +
 net/mac80211/trace.h                           |   35 +
 net/mac80211/tx.c                              |   39 +-
 net/mac80211/util.c                            |  162 +-
 net/mac80211/vht.c                             |    4 +-
 net/wireless/chan.c                            |    1 +
 net/wireless/core.h                            |    9 -
 net/wireless/debugfs.c                         |   24 +-
 net/wireless/genregdb.awk                      |    6 +
 net/wireless/nl80211.c                         |   52 +-
 net/wireless/reg.c                             |   14 +-
 net/wireless/util.c                            |    9 +
 89 files changed, 11937 insertions(+), 1309 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wcn36xx/Kconfig
 create mode 100644 drivers/net/wireless/ath/wcn36xx/Makefile
 create mode 100644 drivers/net/wireless/ath/wcn36xx/debug.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/debug.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/dxe.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/dxe.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/hal.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/main.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/pmc.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/pmc.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/smd.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/smd.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/txrx.c
 create mode 100644 drivers/net/wireless/ath/wcn36xx/txrx.h
 create mode 100644 drivers/net/wireless/ath/wcn36xx/wcn36xx.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSYCsrAAoJEJctW/TcYTgGIGgP/iO6jMWytA0sMLCD7GeBhvdp
j5vyjZ9j0v+Fpq4s9g6ALygnAEa2lILu+fI1pVafH0i9f1HtzNkFZNTIknEB/3CP
zBJUcNMB9B0UrZ2vuyqgUMLIiWWoqFuMtO2DGrSFTT9DFaQVX6Ubfw7wqDa4dsmS
LsfZ0yPuKdifGjjGvNT7N6+6woq1zV0DwUPOX+x0jzCREwJ3uefbn3ylm2bowdbB
n1AZB9Qj01wS7jzEiUQ/p8xba4i62woaF2dHFH+YNRWxyGOR7ZjDGkrtvYDHeEvc
hL+NkrtFPk+HzcMfRvhn1zoE7ljGmKIm49QBs6wGg181ZaXr/9FpGC3KuICqP06v
6fijML13hDzRohVPGTpjxNPpMnnR8Iyqq5uE8aLd3AL++ke87Az6DCBOmLp313Uf
OkWR7awNTVlU2Jj6ziSULPL0k6fwdiJ7abVGZTLH0+Rl4CgGMwAPi2aDBzwh0ejV
/bMOWkg9zz8Inn43wUANzODKQacFW6ZIM3iXV9kgV/63F6wrG+7bV0EM21s4RS1h
JBJrImjESkVvv0m6Iej3O8g0XH3AkofkEUK6vgNQWEIVOQ+nPCkzPiex8kxJh9wv
unekNRyHiTihY4tfFaYqVKYXX+vrgi8RWNvh9qog3Md+P4glOeGhj1B+GDo8uktl
VP8veovW34Dh7k7d0TGn
=j+Lp
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
