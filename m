From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-01-05
Date: Wed, 5 Jan 2011 16:51:34 -0500
Message-ID: <20110105215133.GA2369@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another big batch of updates intended for 2.6.38.  It should
be the last big one, but I still have a few patches in the queue that m=
eet
the posting date requirements and that might merit inclusion -- we'll
see...

Again, this is the usual batch of driver updates from all the major
players.  Also, mac80211 gets a little action.  The bluetooth team make=
s
a showing as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit dbbe68bb12b34f3e450da7a73c20e6fa1f85=
d63a:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
davem/net-2.6 (2011-01-04 11:57:25 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Akinobu Mita (1):
      airo: use simple_write_to_buffer

Bob Copeland (2):
      ath5k: fix cycle counter inconsistent locking
      cfg80211: fix transposition of words in printk

Brian Prodoehl (1):
      ath9k: fix spur mitigation no-spur case for AR9002

Bruno Randolf (6):
      ath5k: Simplify powertable recalculation
      ath5k: Separate powertable setup and writing
      ath5k: Track current TX power separately from max TX power
      ath5k: Remove ATH5K_INI_RFGAIN defines, use band instead
      ath5k: Use helper function to get eeprom mode from channel
      ath5k: Move mac80211 functions into new file

Chaoming Li (1):
      rtlwifi: Fix large packet issue

Christian Lamparter (6):
      carl9170: add missing return-value check
      carl9170: reduce channel change delay
      carl9170: fix usb pm suspend->resume woes
      mac80211: ignore PSM bit of reordered frames
      mac80211: serialize rx path workers
      Revert "mac80211: temporarily disable reorder release timer"

Dan Carpenter (2):
      ath9k: unlock on error path in ath9k_change_interface()
      ath5k: ath5k_eeprom_mode_from_channel() returns signed

=46elix Fietkau (1):
      ath9k_hw: fix dma descriptor rx error bit parsing

Gertjan van Wingerde (3):
      rt2x00: Remove intf->bssid field.
      rt2x00: remove intf->mac field.
      rt2x00: Fix pointer errors.

Gustavo F. Padovan (2):
      Bluetooth: Don't accept ConfigReq if we aren't in the BT_CONFIG s=
tate
      Bluetooth: Improve handling of HCI control channel in bind

Hauke Mehrtens (7):
      wl1251: remove unnecessary import
      wl12xx: remove unnecessary import
      ssb: Use pci_is_pcie()
      rt2x00: Use pci_is_pcie()
      ath5k: Use pci_is_pcie()
      ath9k: Use pci_is_pcie()
      rtlwifi: Use pci_pcie_cap()

Helmut Schaa (4):
      rt2x00: Remove superfluous assignment of mpdu_density
      rt2x00: Simplify intf->delayed_flags locking
      rt2x00: Remove unused interface spinlock
      rt2x00: Fix comment about removed spinlock

Ismael Luceno (1):
      rt2x00: Fix panic on frame padding for rt2800 usb devices

Joel A Fernandes (1):
      mac80211: Fix mesh portal communication with other mesh nodes.

Johan Hedberg (9):
      Bluetooth: Add Bluetooth Management interface definitions
      Bluetooth: Add initial Bluetooth Management interface callbacks
      Bluetooth: Make hci_send_to_sock usable for management control so=
ckets
      Bluetooth: Add error handling for managment command handlers
      Bluetooth: Add read_version management command
      Bluetooth: Add read_index_list management command
      Bluetooth: Add read_info management command
      Bluetooth: Add management events for controller addition & remova=
l
      Bluetooth: Fix __hci_request synchronization for hci_open_dev

Johannes Berg (7):
      mac80211: cleanup select_queue
      iwlagn: fix FH error
      mac80211: add missing synchronize_rcu
      mac80211: fix some key comments and code
      mac80211: implement hardware offload for remain-on-channel
      mac80211: implement off-channel TX using hw r-o-c offload
      mac80211: remove stray extern

Johannes Stezenbach (2):
      rt2x00: simplify txstatus_fifo handling
      rt2x00: allow txstatus_fifo w/o txstatus_tasklet

John W. Linville (8):
      rtl818x: move rtl8180 and rtl8187 to separate subdirectories
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-next-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      ath9k: qualify global modparam_nohwcrypt variable
      ath5k: qualify global modparam_nohwcrypt variable
      ath9k: correct MODULE_PARM_DESC parameters for force_new_ani
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jussi Kivilinna (7):
      rndis_wlan: scanning, workaround device returning incorrect bssid=
-list item count.
      rndis_wlan: do not set default_key if not WEP key
      rndis_wlan: turn radio off before interface is bring up
      rndis_wlan: constify rndis_config_ops
      rndis_wlan: remove unused variable from priv structure
      rndis_wlan: add support for set_cqm_rssi_config
      rndis_wlan: add support for set_power_mgmt

Larry Finger (1):
      rtlwifi: rtl8192ce: Fix driver problem when radio switch off at m=
odule load

Luis R. Rodriguez (1):
      ath9k: fix aphy / wiphy idle mismatch

Milton Miller (1):
      mac80211: fix mesh forwarding when ratelimited too

Mohammed Shafi Shajakhan (4):
      ath9k: Reset keycache on resume
      ath9k: Few clean ups in beacon config parameters
      Revert "ath9k: Parse DTIM period from mac80211"
      ath9k : few rate control clean ups

Rafa=C5=82 Mi=C5=82ecki (7):
      b43: use correct firmware for newer cores
      b43: N-PHY: implement radio 2056 init steps
      b43: N-PHY: add init tables for 2056 radio
      b43: N-PHY: avoid PHY hangs for rev 3 and 4
      b43: N-PHY: use correct channel tables for rev4+
      b43: N-PHY: update 2056 radio on channel switch on rev3+
      b43: N-PHY: enable support for PHYs rev 3 and higher

Rajkumar Manoharan (2):
      ath9k: Fix warnings on card removal
      ath9k: fix beacon restart on channel change

Senthil Balasubramanian (1):
      ath9k: spin_lock_bh is not required within tasklet context.

Stanislaw Gruszka (2):
      iwlagn: enable only rfkill interrupt when device is down
      iwlagn: fix scan tx antenna setting on 5Ghz band

Sujith Manoharan (7):
      ath9k_htc: Fix warning on device removal
      ath9k_htc: Handle pending URBs properly
      ath9k_htc: Move work cancellation outside of mutex
      ath9k_htc: Handle FATAL events
      ath9k_htc: Fix fast channel change
      ath9k_htc: Move LED/RFKILL code to htc_drv_gpio.c
      ath9k_htc: Fix packet injection

Tracey Dent (1):
      Net: bluetooth: Makefile: Remove deprecated kbuild goal definitio=
ns

Vasanthakumar Thiagarajan (1):
      ath9k_hw: Fix bug in eeprom data length validation for AR9485

Wey-Yi Guy (2):
      iwlwifi: remove extra string
      iwlwifi: remove reference to Gen2

roel kluin (1):
      libertas: down_interruptible() can return -EINTR, not EINTR

 MAINTAINERS                                        |    4 +-
 drivers/net/wireless/airo.c                        |   20 +-
 drivers/net/wireless/ath/ath5k/Makefile            |    1 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |    8 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    2 +-
 drivers/net/wireless/ath/ath5k/base.c              |  769 +-----
 drivers/net/wireless/ath/ath5k/eeprom.c            |   16 +
 drivers/net/wireless/ath/ath5k/eeprom.h            |    2 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |  774 +++++
 drivers/net/wireless/ath/ath5k/phy.c               |  152 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   28 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   11 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   25 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 -
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   46 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    1 +
 drivers/net/wireless/ath/ath9k/htc.h               |   31 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |  327 +++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   16 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  460 +---
 drivers/net/wireless/ath/ath9k/hw.c                |    4 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    4 +
 drivers/net/wireless/ath/ath9k/init.c              |   13 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    9 +-
 drivers/net/wireless/ath/ath9k/main.c              |   21 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   13 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   16 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    3 -
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |   20 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |    3 +-
 drivers/net/wireless/ath/carl9170/phy.c            |   10 +-
 drivers/net/wireless/ath/carl9170/usb.c            |   53 +-
 drivers/net/wireless/b43/main.c                    |   14 +-
 drivers/net/wireless/b43/phy_n.c                   |  130 +-
 drivers/net/wireless/b43/radio_2056.c              | 3045 ++++++++++++=
+++++++-
 drivers/net/wireless/b43/radio_2056.h              |    3 +
 drivers/net/wireless/iwlwifi/iwl-6000.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   18 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    1 -
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |    6 +
 drivers/net/wireless/iwlwifi/iwl-led.c             |    2 +-
 drivers/net/wireless/libertas/if_spi.c             |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |  192 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   18 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   16 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   25 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    8 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   25 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |    2 -
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   35 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    2 +-
 drivers/net/wireless/rtl818x/Makefile              |    9 +-
 drivers/net/wireless/rtl818x/rtl8180/Makefile      |    5 +
 .../rtl818x/{rtl8180_dev.c =3D> rtl8180/dev.c}       |    8 +-
 .../{rtl8180_grf5101.c =3D> rtl8180/grf5101.c}       |    2 +-
 .../{rtl8180_grf5101.h =3D> rtl8180/grf5101.h}       |    0
 .../{rtl8180_max2820.c =3D> rtl8180/max2820.c}       |    2 +-
 .../{rtl8180_max2820.h =3D> rtl8180/max2820.h}       |    0
 .../net/wireless/rtl818x/{ =3D> rtl8180}/rtl8180.h   |    0
 .../{rtl8180_rtl8225.c =3D> rtl8180/rtl8225.c}       |    2 +-
 .../{rtl8180_rtl8225.h =3D> rtl8180/rtl8225.h}       |    0
 .../rtl818x/{rtl8180_sa2400.c =3D> rtl8180/sa2400.c} |    2 +-
 .../rtl818x/{rtl8180_sa2400.h =3D> rtl8180/sa2400.h} |    0
 drivers/net/wireless/rtl818x/rtl8187/Makefile      |    5 +
 .../rtl818x/{rtl8187_dev.c =3D> rtl8187/dev.c}       |    6 +-
 .../rtl818x/{rtl8187_leds.c =3D> rtl8187/leds.c}     |    2 +-
 .../rtl818x/{rtl8187_leds.h =3D> rtl8187/leds.h}     |    0
 .../rtl818x/{rtl8187_rfkill.c =3D> rtl8187/rfkill.c} |    2 +-
 .../rtl818x/{rtl8187_rfkill.h =3D> rtl8187/rfkill.h} |    0
 .../net/wireless/rtl818x/{ =3D> rtl8187}/rtl8187.h   |    2 +-
 .../{rtl8187_rtl8225.c =3D> rtl8187/rtl8225.c}       |    2 +-
 .../{rtl8187_rtl8225.h =3D> rtl8187/rtl8225.h}       |    0
 drivers/net/wireless/rtlwifi/base.c                |   12 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   11 -
 drivers/net/wireless/wl1251/boot.c                 |    1 -
 drivers/net/wireless/wl12xx/boot.c                 |    1 -
 drivers/ssb/scan.c                                 |    4 +-
 include/net/bluetooth/bluetooth.h                  |    1 +
 include/net/bluetooth/hci.h                        |    4 +
 include/net/bluetooth/hci_core.h                   |    9 +-
 include/net/bluetooth/mgmt.h                       |   87 +
 include/net/mac80211.h                             |   19 +
 net/bluetooth/Makefile                             |    2 +-
 net/bluetooth/hci_core.c                           |   17 +-
 net/bluetooth/hci_event.c                          |   33 +-
 net/bluetooth/hci_sock.c                           |   52 +-
 net/bluetooth/l2cap.c                              |    8 +-
 net/bluetooth/mgmt.c                               |  308 ++
 net/mac80211/cfg.c                                 |  142 +
 net/mac80211/driver-ops.h                          |   30 +
 net/mac80211/driver-trace.h                        |   80 +
 net/mac80211/ieee80211_i.h                         |   21 +
 net/mac80211/iface.c                               |    9 +-
 net/mac80211/key.c                                 |   44 +-
 net/mac80211/led.c                                 |    4 +-
 net/mac80211/main.c                                |    8 +-
 net/mac80211/offchannel.c                          |   85 +
 net/mac80211/rx.c                                  |  112 +-
 net/mac80211/tx.c                                  |   14 +-
 net/mac80211/wme.c                                 |   20 +-
 net/wireless/reg.c                                 |    2 +-
 108 files changed, 6014 insertions(+), 1642 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/mac80211-ops.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8180/Makefile
 rename drivers/net/wireless/rtl818x/{rtl8180_dev.c =3D> rtl8180/dev.c}=
 (99%)
 rename drivers/net/wireless/rtl818x/{rtl8180_grf5101.c =3D> rtl8180/gr=
f5101.c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8180_grf5101.h =3D> rtl8180/gr=
f5101.h} (100%)
 rename drivers/net/wireless/rtl818x/{rtl8180_max2820.c =3D> rtl8180/ma=
x2820.c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8180_max2820.h =3D> rtl8180/ma=
x2820.h} (100%)
 rename drivers/net/wireless/rtl818x/{ =3D> rtl8180}/rtl8180.h (100%)
 rename drivers/net/wireless/rtl818x/{rtl8180_rtl8225.c =3D> rtl8180/rt=
l8225.c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8180_rtl8225.h =3D> rtl8180/rt=
l8225.h} (100%)
 rename drivers/net/wireless/rtl818x/{rtl8180_sa2400.c =3D> rtl8180/sa2=
400.c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8180_sa2400.h =3D> rtl8180/sa2=
400.h} (100%)
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187/Makefile
 rename drivers/net/wireless/rtl818x/{rtl8187_dev.c =3D> rtl8187/dev.c}=
 (99%)
 rename drivers/net/wireless/rtl818x/{rtl8187_leds.c =3D> rtl8187/leds.=
c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8187_leds.h =3D> rtl8187/leds.=
h} (100%)
 rename drivers/net/wireless/rtl818x/{rtl8187_rfkill.c =3D> rtl8187/rfk=
ill.c} (98%)
 rename drivers/net/wireless/rtl818x/{rtl8187_rfkill.h =3D> rtl8187/rfk=
ill.h} (100%)
 rename drivers/net/wireless/rtl818x/{ =3D> rtl8187}/rtl8187.h (99%)
 rename drivers/net/wireless/rtl818x/{rtl8187_rtl8225.c =3D> rtl8187/rt=
l8225.c} (99%)
 rename drivers/net/wireless/rtl818x/{rtl8187_rtl8225.h =3D> rtl8187/rt=
l8225.h} (100%)
 create mode 100644 include/net/bluetooth/mgmt.h
 create mode 100644 net/bluetooth/mgmt.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-01-05.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
