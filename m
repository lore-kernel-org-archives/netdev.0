From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-05-22
Date: Fri, 22 May 2009 14:32:39 -0400
Message-ID: <20090522183238.GE3559@tuxdriver.com>
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

Another huge dump of stuff intended for 2.6.31...it seems like it never
stops!  I guess that is mostly good... :-)

There are a bunch of driver updates, some mac80211 bits that are fixes
for things already in -next, some similar regulatory fixes/changes for
cfg80211, etc.  Also of note is a new "full MAC" driver for a new
not-quite-available device coming soon from Intel.

Please let me know if there are problems!

Thanks,

John

P.S.  There is a merge-test branch in the wireless-next-2.6 tree.  It
might come-in useful when merging net-2.6 and net-next-2.6...

P.P.S.  I'll be in Barcelona this week, but I'll endeavour to be
reasonably responsive if needed! :-)

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 97bc54152e3a91dd2dc297e8a084c05e9352=
7e60:
  Ben Hutchings (1):
        sfc: Remove lro module parameter

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (1):
      iwl3945: improve 3945 leds

Alexander Beregalov (1):
      Staging: agnx: switch config_interface to bss_info_changed

Alexandre Becholey (1):
      rt73usb: fix for master mode

Bing Zhao (4):
      libertas: define macros for SDIO model numbers
      libertas: get SD8688 rx length with one CMD52
      libertas: implement function init/shutdown commands for SD8688
      libertas: read SD8688 firmware status from new register

Bob Copeland (2):
      ath5k: update beacons in AP mode
      ath5k: avoid and warn on potential infinite loop

Daniel Wagner (1):
      mac80211_hwsim: Group radios

David Kilroy (2):
      cfg80211: mark ops as pointer to const
      cfg80211: mark wiphy->privid as pointer to const

G=E1bor Stefanik (1):
      zd1211rw: Replace ZD_CS_MULTICAST with ZD_CS_NO_ACK

Ivo van Doorn (3):
      rt2x00: Add USB ID for rt2800usb
      rt2x00: Add new rt2800usb USB ID's for Sweex
      rt2x00: Remove usage of IEEE80211_CONF_CHANGE_BEACON_INTERVAL

Johannes Berg (11):
      mac80211: move channel switch code
      mac80211: cancel/restart all timers across suspend/resume
      b43/legacy: fix beacon change processing
      cfg80211: allow wext to remove keys that don't exist
      mac80211: fix kernel-doc
      mac80211: don't try to do anything on unchanged genIE
      mac80211: fix parameter confusion when finding IBSS
      mac80211: fix managed mode BSSID handling
      wext: remove atomic requirement for wireless stats
      mac80211: fix probe response wait timing
      mac80211: correct probe wait time

Jouni Malinen (14):
      mac80211: Cancel pending probereq poll on beacon RX
      ath9k: Fix a check for multicast address for virtual wiphy
      ath9k: Clean up RX processing a bit
      ath9k: Fix PS mode operation to receive buffered broadcast/multic=
ast frames
      nl80211: Validate NL80211_ATTR_KEY_SEQ length
      ath9k: Wake up for TX in mac80211 timeout=3D0 sleep mode
      ath9k: Do not try to calibrate radio when in sleep mode
      ath9k: Use TSFOOR interrupt to trigger TSF sync with next Beacon
      ath9k: Wake up for RX filter changes
      ath9k: Set PM field in frame control when in PS mode
      mac80211: PS processing for every Beacon with our AID in TIM
      mac80211: Do not override AID in the duration field
      ath9k: Optimize TBTT/DTIM calculation for timers
      ath9k: Update Beacon timers based on timestamp from the AP

Julia Lawall (1):
      drivers/net: use dev_get_drvdata

Jussi Kivilinna (5):
      rndis_wlan: fix support for bcm4320a
      rndis_wlan: remove CAP_SUPPORT_TXPOWER/OID_802_11_TX_POWER_LEVEL =
code
      rndis_wlan: explain bits used in key setup code.
      rndis_wlan: split add_wpa_key from rndis_iw_set_encode_ext
      rndis_wlan: do not try to restore wpa keys using add_wep_key()

Luis R. Rodriguez (12):
      cfg80211: Process regulatory max bandwidth checks for HT40
      wireless: rename IEEE80211_CHAN_NO_FAT_* to HT40-/+
      mac80211: check if HT40+/- is allowed before sending assoc
      cfg80211: check allowed channel type upon userspace requests
      mac80211/cfg80211: move wiphy specific debugfs entries to cfg8021=
1
      cfg80211: add debugfs HT40 allow map
      cfg80211: return immediately if num reg rules > NL80211_MAX_SUPP_=
REG_RULES
      cfg80211: cleanup return calls on nl80211_set_reg()
      cfg80211: fix in nl80211_set_reg()
      ath9k: fix custom regulatory call position
      ath9k: set max default eirp to 20 dBm
      cfg80211: warn when wiphy_apply_custom_regulatory() does nothing

Max Filippov (6):
      p54spi: fix incorrect access sequence to DMA_WRITE_CTRL in p54spi=
_spi_write_dma
      p54spi: cosmetic fixes: use even byte count in SPI write; drop un=
used interrupt status read
      p54spi: return status of p54spi_wakeup
      p54spi: always call p54spi_sleep in p54spi_tx_frame if p54spi_wak=
eup succeeded
      p54spi: use firmware/DMA bug workaround that work under hight loa=
d in p54spi_rx
      p54spi: drop test for FW_STATE_RESET in p54spi_work

Mohamed Abbas (6):
      iwlcore: register locks
      iwlcore: support ICT interrupt
      iwlcore: Allow skb allocation from tasklet.
      iwlcore: Add support for periodic RX interrupt
      iwlcore: Set rb_timeout to 0x10 for devices with ICT
      iwlagn: co-exist with AMT

Pavel Roskin (1):
      cfg80211: fix compile error with CONFIG_CFG80211_DEBUGFS

Senthil Balasubramanian (1):
      mac80211: Initialize RX's last received sequence number

Stefano Brivio (1):
      b43legacy: Remove unnecessary MMIO in interrupt hotpath

Tomas Winkler (2):
      iwlwifi: drop struct iwl3945_hw_key
      iwlwifi: drop iwl3945_tid_data

Vasanthakumar Thiagarajan (4):
      ath9k: Print hw reset failure status as signed int
      ath9k: Remove unused parameters which are passed to ath_beacon_co=
nfig_X()
      ath9k: cleanup beacon parameters configuration
      ath9k: Move PS wakeup/restore calls from isr to tasklet

Wei Yongjun (1):
      wireless: fix to set dev->broadcast correctly

Wey-Yi Guy (6):
      iwlwifi: add Greenfield support for 11n
      iwlwifi: Temperature sensor voltage reading for 5150
      iwlwifi: support NVM access (EEPROM/OTP)
      iwlwifi: report the rate index as an MCS rate number
      iwlwifi: support "pure 40MHz" in RXON command
      iwlwifi: check for valid band for channel info

Zhu Yi (2):
      wireless: move some utility functions from mac80211 to cfg80211
      iwmc3200wifi: Add new Intel Wireless Multicomm 802.11 driver

andrey-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org (1):
      libertas: fix GSPI card event handling

 Documentation/DocBook/mac80211.tmpl          |    1 -
 drivers/net/wireless/Kconfig                 |    1 +
 drivers/net/wireless/Makefile                |    2 +
 drivers/net/wireless/ath/ar9170/main.c       |    2 +-
 drivers/net/wireless/ath/ath5k/base.c        |   54 +-
 drivers/net/wireless/ath/ath5k/pcu.c         |    4 +-
 drivers/net/wireless/ath/ath5k/phy.c         |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h       |    9 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |   98 +-
 drivers/net/wireless/ath/ath9k/debug.h       |    1 +
 drivers/net/wireless/ath/ath9k/hw.c          |    8 +-
 drivers/net/wireless/ath/ath9k/main.c        |  119 ++-
 drivers/net/wireless/ath/ath9k/recv.c        |  194 +++-
 drivers/net/wireless/ath/ath9k/xmit.c        |   12 +-
 drivers/net/wireless/ath/regd.c              |   10 +-
 drivers/net/wireless/b43/main.c              |   26 +-
 drivers/net/wireless/b43legacy/b43legacy.h   |    4 +-
 drivers/net/wireless/b43legacy/main.c        |   99 +--
 drivers/net/wireless/b43legacy/pio.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c  |   70 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |  151 +---
 drivers/net/wireless/iwlwifi/iwl-4965.c      |   88 +--
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h   |   12 +
 drivers/net/wireless/iwlwifi/iwl-5000.c      |  164 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  355 ++++++-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   14 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  392 ++++++--
 drivers/net/wireless/iwlwifi/iwl-core.h      |   41 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h       |   22 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |   97 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   32 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |  153 +++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |    4 +
 drivers/net/wireless/iwlwifi/iwl-io.h        |  253 +++--
 drivers/net/wireless/iwlwifi/iwl-rx.c        |   63 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   17 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   87 +--
 drivers/net/wireless/iwmc3200wifi/Kconfig    |   23 +
 drivers/net/wireless/iwmc3200wifi/Makefile   |    5 +
 drivers/net/wireless/iwmc3200wifi/bus.h      |   57 +
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |  409 ++++++++
 drivers/net/wireless/iwmc3200wifi/cfg80211.h |   31 +
 drivers/net/wireless/iwmc3200wifi/commands.c |  920 +++++++++++++++++
 drivers/net/wireless/iwmc3200wifi/commands.h |  419 ++++++++
 drivers/net/wireless/iwmc3200wifi/debug.h    |  124 +++
 drivers/net/wireless/iwmc3200wifi/debugfs.c  |  453 ++++++++
 drivers/net/wireless/iwmc3200wifi/eeprom.c   |  187 ++++
 drivers/net/wireless/iwmc3200wifi/eeprom.h   |  114 ++
 drivers/net/wireless/iwmc3200wifi/fw.c       |  388 +++++++
 drivers/net/wireless/iwmc3200wifi/fw.h       |  100 ++
 drivers/net/wireless/iwmc3200wifi/hal.c      |  464 +++++++++
 drivers/net/wireless/iwmc3200wifi/hal.h      |  236 +++++
 drivers/net/wireless/iwmc3200wifi/iwm.h      |  350 +++++++
 drivers/net/wireless/iwmc3200wifi/lmac.h     |  457 ++++++++
 drivers/net/wireless/iwmc3200wifi/main.c     |  680 ++++++++++++
 drivers/net/wireless/iwmc3200wifi/netdev.c   |  172 +++
 drivers/net/wireless/iwmc3200wifi/rfkill.c   |   88 ++
 drivers/net/wireless/iwmc3200wifi/rx.c       | 1431 ++++++++++++++++++=
++++++++
 drivers/net/wireless/iwmc3200wifi/rx.h       |   60 ++
 drivers/net/wireless/iwmc3200wifi/sdio.c     |  516 ++++++++++
 drivers/net/wireless/iwmc3200wifi/sdio.h     |   67 ++
 drivers/net/wireless/iwmc3200wifi/tx.c       |  492 +++++++++
 drivers/net/wireless/iwmc3200wifi/umac.h     |  744 +++++++++++++
 drivers/net/wireless/iwmc3200wifi/wext.c     |  723 +++++++++++++
 drivers/net/wireless/libertas/dev.h          |    2 +
 drivers/net/wireless/libertas/host.h         |    2 +
 drivers/net/wireless/libertas/if_sdio.c      |  149 +++-
 drivers/net/wireless/libertas/if_sdio.h      |    8 +
 drivers/net/wireless/libertas/if_spi.c       |    7 +
 drivers/net/wireless/libertas/main.c         |   20 +
 drivers/net/wireless/mac80211_hwsim.c        |   35 +-
 drivers/net/wireless/p54/p54spi.c            |   64 +-
 drivers/net/wireless/rndis_wlan.c            |  216 +++--
 drivers/net/wireless/rt2x00/rt2400pci.c      |   30 +-
 drivers/net/wireless/rt2x00/rt2500pci.c      |   30 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |   17 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |   25 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    2 +
 drivers/net/wireless/rt2x00/rt2x00config.c   |    1 +
 drivers/net/wireless/rt2x00/rt2x00crypto.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    9 +-
 drivers/net/wireless/rt2x00/rt61pci.c        |   28 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |   28 +-
 drivers/net/wireless/strip.c                 |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.h       |    2 +-
 drivers/staging/agnx/pci.c                   |   15 +-
 include/linux/ieee80211.h                    |    9 +
 include/net/cfg80211.h                       |   78 ++-
 include/net/mac80211.h                       |   29 -
 net/mac80211/debugfs.c                       |   16 -
 net/mac80211/ibss.c                          |   33 +-
 net/mac80211/ieee80211_i.h                   |   43 +-
 net/mac80211/key.c                           |    6 +-
 net/mac80211/main.c                          |   16 +-
 net/mac80211/mesh.c                          |   40 +
 net/mac80211/mesh.h                          |   16 +-
 net/mac80211/mesh_hwmp.c                     |    8 +-
 net/mac80211/mesh_plink.c                    |   21 +
 net/mac80211/mlme.c                          |  227 ++++-
 net/mac80211/pm.c                            |   80 ++-
 net/mac80211/rx.c                            |   94 +--
 net/mac80211/scan.c                          |   18 +
 net/mac80211/spectmgmt.c                     |  101 --
 net/mac80211/sta_info.c                      |    6 +
 net/mac80211/sta_info.h                      |    2 +
 net/mac80211/tx.c                            |    2 +
 net/mac80211/util.c                          |  116 +--
 net/mac80211/wext.c                          |    5 +-
 net/mac80211/wme.c                           |   30 +-
 net/wireless/Kconfig                         |    8 +
 net/wireless/Makefile                        |    1 +
 net/wireless/core.c                          |    7 +-
 net/wireless/core.h                          |   14 +-
 net/wireless/debugfs.c                       |  131 +++
 net/wireless/debugfs.h                       |   14 +
 net/wireless/nl80211.c                       |   66 +-
 net/wireless/reg.c                           |  216 +++-
 net/wireless/util.c                          |  320 ++++++
 net/wireless/wext-compat.c                   |    7 +
 net/wireless/wext.c                          |   32 +-
 124 files changed, 13213 insertions(+), 1745 deletions(-)
 create mode 100644 drivers/net/wireless/iwmc3200wifi/Kconfig
 create mode 100644 drivers/net/wireless/iwmc3200wifi/Makefile
 create mode 100644 drivers/net/wireless/iwmc3200wifi/bus.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/cfg80211.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/cfg80211.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/commands.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/commands.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/debug.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/debugfs.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/eeprom.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/eeprom.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/fw.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/fw.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/hal.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/hal.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/iwm.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/lmac.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/main.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/netdev.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/rfkill.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/rx.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/rx.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/sdio.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/sdio.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/tx.c
 create mode 100644 drivers/net/wireless/iwmc3200wifi/umac.h
 create mode 100644 drivers/net/wireless/iwmc3200wifi/wext.c
 create mode 100644 net/wireless/debugfs.c
 create mode 100644 net/wireless/debugfs.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-05-22.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
