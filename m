From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-03-17
Date: Tue, 17 Mar 2009 15:21:29 -0400
Message-ID: <20090317192129.GG6737@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52672 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbZCQTaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 15:30:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Top o' the mornin' to ya!

Here is another big round of wireless updates intended for 2.6.30.  The=
y
just keep coming!  Lots of driver bits and some more regulatory stuff
from Luis...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit afece1c6587010cc81d1a43045c855774e82=
34a3:
  Ilpo J=E4rvinen (1):
        tcp: make sure xmit goal size never becomes zero

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (5):
      iwl3945: add test for new association
      iwl3945: fix sparse error
      iwl3945: use iwl_led structure
      iwl3945 : fix rate scaling
      iwl3945: use iwl_tx_cmd_complete

Andrey Borzenkov (1):
      orinoco: firmware: consistently compile out fw cache support if n=
ot requested

Bob Copeland (3):
      ath5k: extract LED code into a separate file
      ath5k: use a table for LED parameters
      ath5k: update LED table with reported devices

Christian Lamparter (7):
      p54usb: stop USB core interference in exit path
      p54: unify ieee80211 device registration
      p54pci: convert printk(KERN_* to dev_*
      p54: fix iwconfig txpower off
      p54: initial SoftLED support
      p54: enable power save support
      p54: completely ignore rx'd frames with bad FCS

Gabor Juhos (7):
      ath9k: create a common debugfs_root for all device instances
      ath9k: cleanup AR5416 version checking macros
      ath9k: move ar9100 version checking macros into a more appropriat=
e place
      ath9k: fix AR_SREV_9100_OR_LATER macro
      ath9k: fix compile error in ahb.c
      ath9k: fix compile error in debug.c
      ath9k: always compile ath_radio_{en,dis}able

Helmut Schaa (5):
      libipw: fix debug output
      ipw2x00: remove duplicated defines
      ipw2x00: Use IE definitions from linux/ieee80211.h
      ipw2x00: remove obsolete enums
      mac80211: handle failed scan requests in STA mode

Herton Ronaldo Krzesinski (1):
      mac80211: deauth before flushing STA information

Jay Sternberg (1):
      iwlwifi: correct device name for 1000 series

Jiri Slaby (2):
      ath5k: constify stuff
      ath5k: don't change mac in eeprom_read_mac on error

John Daiker (3):
      airo_cs: checkpatch.pl cleanups
      atmel: checkpatch.pl cleanups
      ray_cs: checkpatch.pl and Lindent cleanups

Jouni Malinen (2):
      mac80211: Fix WMM ACM parsing and AC downgrade operation
      ath9k: Fix FIF_PROMISC_IN_BSS processing in station mode

Lennert Buytenhek (1):
      mwl8k: Marvell TOPDOG wireless driver

Luis R. Rodriguez (9):
      mac80211_hwsim: add support for 5 GHz
      cfg80211: Enable passive scan on channels 12-14 for world roaming
      cfg80211: fix max tx power for world regdom on 5 GHz to 20dBm
      cfg80211: remove REGDOM_SET_BY_INIT
      cfg80211: move enum reg_set_by to nl80211.h
      cfg80211: add regulatory netlink multicast group
      mac80211_hwsim: add regulatory testing options
      ath9k: downgrade xmit queue full message to xmit debug
      ath9k: make few eeprom and calib items static

Mohamed Abbas (1):
      iwlagn: fix warning when set WEP key

Reinette Chatre (3):
      iwl3945: unmap previously mapped memory
      iwlwifi: print contents of control register when error occurs
      iwlwifi: correct log level when error occurs

Senthil Balasubramanian (4):
      ath9k: Get rid of unnecessary ATOMIC memory alloc during init tim=
e
      ath9k: RX buffers may be accessed/freed even before initialized/a=
lloced.
      ath9k: INI update for AR9285 and periodic PA offset caliberation
      ath9k: Incorrect AR9285 version check macro

Sujith (4):
      ath9k: Initialize ANI properly
      ath9k: Fix bug in TX aggregation
      ath9k: Fix bug in reading debugfs file 'rcstat'
      ath9k: Add spectrum management to HW capabilities

Vasanthakumar Thiagarajan (1):
      ath9k: Use suitable macros with 4k eeprom data

Wey-Yi Guy (6):
      iwlwifi: add valid tx antenna information in rate_scale_table deb=
ugfs
      iwlwifi: add rf information in rate_scale debugfs command
      iwlwifi: remove un-necessary rs_tl_turn_on_agg() after agg enable=
d
      iwlwifi: HT performance improvement changes
      iwlwifi: check IEEE80211_TX_STAT_AMPDU for agg pkt
      iwlwifi: verify the antenna selection when receive fixed rate deb=
ugfs

 drivers/net/wireless/Kconfig                       |    9 +
 drivers/net/wireless/Makefile                      |    2 +
 drivers/net/wireless/airo_cs.c                     |   73 +-
 drivers/net/wireless/ath5k/Makefile                |    1 +
 drivers/net/wireless/ath5k/ath5k.h                 |    6 +
 drivers/net/wireless/ath5k/attach.c                |   13 +-
 drivers/net/wireless/ath5k/base.c                  |  148 +-
 drivers/net/wireless/ath5k/debug.c                 |   10 +-
 drivers/net/wireless/ath5k/eeprom.c                |    9 +-
 drivers/net/wireless/ath5k/led.c                   |  174 +
 drivers/net/wireless/ath5k/reset.c                 |    2 +-
 drivers/net/wireless/ath9k/ahb.c                   |    1 +
 drivers/net/wireless/ath9k/calib.c                 |  145 +-
 drivers/net/wireless/ath9k/debug.c                 |   29 +-
 drivers/net/wireless/ath9k/debug.h                 |   12 +-
 drivers/net/wireless/ath9k/eeprom.c                |   34 +-
 drivers/net/wireless/ath9k/eeprom.h                |    2 +-
 drivers/net/wireless/ath9k/hw.c                    |   37 +-
 drivers/net/wireless/ath9k/initvals.h              |  151 +-
 drivers/net/wireless/ath9k/mac.h                   |    2 +-
 drivers/net/wireless/ath9k/main.c                  |   37 +-
 drivers/net/wireless/ath9k/phy.h                   |    4 +
 drivers/net/wireless/ath9k/recv.c                  |   19 +-
 drivers/net/wireless/ath9k/reg.h                   |   34 +-
 drivers/net/wireless/ath9k/regd.c                  |   32 +-
 drivers/net/wireless/ath9k/regd.h                  |    3 +-
 drivers/net/wireless/ath9k/xmit.c                  |   51 +-
 drivers/net/wireless/atmel.c                       |  443 ++-
 drivers/net/wireless/ipw2x00/ieee80211.h           |  107 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |   16 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |  100 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   12 +-
 drivers/net/wireless/iwlwifi/Makefile              |    5 +-
 .../net/wireless/iwlwifi/{iwl-100.c =3D> iwl-1000.c} |   20 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |   66 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |  127 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |    8 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   11 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    7 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   93 +-
 drivers/net/wireless/mac80211_hwsim.c              |  348 ++-
 drivers/net/wireless/mwl8k.c                       | 3789 ++++++++++++=
+++++++
 drivers/net/wireless/orinoco/fw.c                  |   37 +-
 drivers/net/wireless/orinoco/fw.h                  |    5 +
 drivers/net/wireless/orinoco/main.c                |    2 +
 drivers/net/wireless/orinoco/orinoco.h             |    2 +
 drivers/net/wireless/p54/p54.h                     |   26 +
 drivers/net/wireless/p54/p54common.c               |  154 +-
 drivers/net/wireless/p54/p54common.h               |    7 +-
 drivers/net/wireless/p54/p54pci.c                  |   36 +-
 drivers/net/wireless/p54/p54spi.c                  |    9 +-
 drivers/net/wireless/p54/p54usb.c                  |    7 +-
 drivers/net/wireless/ray_cs.c                      | 3808 ++++++++++--=
--------
 include/linux/nl80211.h                            |   67 +
 include/net/cfg80211.h                             |   27 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/iface.c                               |   16 +-
 net/mac80211/mlme.c                                |   38 +-
 net/mac80211/scan.c                                |   12 +
 net/mac80211/wme.c                                 |    9 +-
 net/wireless/core.c                                |   13 +-
 net/wireless/core.h                                |    3 +-
 net/wireless/nl80211.c                             |   62 +
 net/wireless/nl80211.h                             |    5 +
 net/wireless/reg.c                                 |  116 +-
 72 files changed, 7713 insertions(+), 3048 deletions(-)
 create mode 100644 drivers/net/wireless/ath5k/led.c
 rename drivers/net/wireless/iwlwifi/{iwl-100.c =3D> iwl-1000.c} (82%)
 create mode 100644 drivers/net/wireless/mwl8k.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-03-17.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
