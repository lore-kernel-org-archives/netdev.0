From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-10-31
Date: Fri, 31 Oct 2008 19:37:35 -0400
Message-ID: <20081031233735.GH4310@tuxdriver.com>
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

Here is a spooky Halloween pull request for wireless bits intended for
2.6.29 -- Boo!  Are you scared?

There is a ton of stuff here.  The good news is that it has been cookin=
g
in wireless-testing for a while and it seems OK. :-)  There are some
warning in the build like "=E2=80=98__IEEE80211_CONF_SHORT_SLOT_TIME=E2=
=80=99 is
deprecated".  Don't worry, I already have more patches cooking in
wireless-testing that will take care of those warnings in the next
round.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 3685f25de1b0447fff381c420de1e25bd57c=
9efb:
  Harvey Harrison (1):
        misc: replace NIPQUAD()

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Andrey Borzenkov (2):
      orinoco: reload firmware on resume
      orinoco: cache downloadable firmware image in memory for use duri=
ng resume

Andrey Yurovsky (2):
      ath5k: fix mesh point operation
      mac80211: allow all interfaces types to handle RX action frames

Bob Copeland (2):
      mac80211: fix a few typos in mac80211 kernel doc
      ath9k: remove useless conditional

Christian Lamparter (6):
      p54: honour bss_info_changed's short slot time settings
      p54: broken out edcf changes
      p54: refactor statistic timer code
      p54: p54: refactor p54_rx_frame_sent
      p54: fix memory management
      p54: borrow some setup code from stlc45xx

Daniel C. Halperin (1):
      iwlwifi: convert correctly rate_n_flags to PLCP index for mimo3 p=
ackets

Daniel Halperin (1):
      iwlwifi: Update reclaim flag

=46abrice Bellet (1):
      iwl3945: iwl3945_mac_get_tsf() should not return zero

=46elix Fietkau (1):
      minstrel: improve performance for non-MRR drivers

Henrique de Moraes Holschuh (5):
      rfkill: use killable locks instead of interruptible
      rfkill: export global states to rfkill-input
      rfkill: add master_switch_mode and EPO lock to rfkill and rfkill-=
input
      rfkill: honour EPO state when resuming a rfkill controller
      rfkill: rate-limit rfkill-input workqueue usage (v3)

Herton Ronaldo Krzesinski (2):
      rtl8187: adapt for deprecated IEEE80211_CONF_SHORT_SLOT_TIME flag
      rtl8187: add short slot handling for 8187B

Jay Sternberg (2):
      iwlwifi: define firmware file name once
      iwlwifi: expand error lookup and align output

Jiri Slaby (1):
      Ath5k: add AP mode

Johannes Berg (35):
      mac80211: remove aggregation status write support from debugfs
      mac80211: remove writable debugs mesh parameters
      mac80211: minor code cleanups
      mac80211: remove wiphy_to_hw
      mac80211: clean up ieee80211_hw_config errors
      mac80211: remove max_antenna_gain config
      mac80211: fix short slot handling
      802.11: clean up/fix HT support
      mac80211: kill hw.conf.antenna_sel_{rx,tx}
      mac80211: introduce hw config change flags
      mac80211: provide sequence numbers
      nl80211: export HT capabilities
      iwl3945: fix station stuff in RC algorithm
      mac80211: make retry limits part of hw config
      mac80211: move bss_conf into vif
      mac80211: rewrite HT handling
      p54/rtl8187: fix up the seqno patch
      mac80211: add might_sleep to hw_config
      mac80211/drivers: rewrite the rate control API
      p54: implement MRR
      make ieee80211 invisible
      nl80211: fix monitor flags
      mac80211: remove rate_control_clear
      mac80211: inform userspace of probe/auth/assoc timeout
      wireless: don't publish __regulatory_hint
      wireless: remove cfg80211_reg_mutex
      wireless: get rid of pointless request list
      wireless: fix EU check
      mac80211: insert AP sta entry after filling it
      wireless: remove write-only 'granted' variable
      wireless: make regdom passing semantics simpler
      wireless: remove struct regdom hinting
      wireless: clean up regulatory ignore_request function
      wireless regulatory: move ignore_request
      mac80211: fix two kernel-doc warnings

John Daiker (2):
      ath5k: reduce checkpatch.pl errors
      rt2x00: reduce checkpatch.pl errors

John W. Linville (6):
      p54: integrate parts of lmac_longbow.h and other parts of stlc45x=
x
      wireless: consolidate on a single escape_essid implementation
      wireless: remove NETWORK_EMPTY_ESSID flag
      wireless: escape_ssid should handle non-printables
      wireless: use individual buffers for printing ssid values
      wireless: avoid some net/ieee80211.h vs. linux/ieee80211.h confli=
cts

Larry Finger (2):
      p54: Move rx_mtu to struct bootrec_desc
      hostap: Fix sparse warnings

Luis R. Rodriguez (8):
      ath5k/ath9k: correct signal quality
      ath9k: correct signal quality report
      ath5k: correct ath5k signal quality
      mac80211: make use of regulatory tx power settings on change of t=
x power
      ath9k: remove pointless sc_txintrperiod and spin_lock_bh on tx pr=
epare
      ath9k: enable RX interrupt mitigation
      ath9k: Allow user to change tx power when asked
      ath9k: use ETH_P_PAE

Mohamed Abbas (1):
      iwlwifi: clear scanning bits upon failure

Nick Kossifidis (1):
      ath5k: Update interrupt masking code

Rami Rosen (3):
      mac80211: remove unused declaration of struct sta_attribute.
      mac80211: use HWSIM_STA_MAGIC in hwsim_check_sta_magic() and hwsi=
m_set_sta_magic().
      mac80211: check return value of dev_alloc_skb() in ieee80211_sta_=
join_ibss().

Sujith (3):
      mac80211: Change WARN_ON to WARN_ON_ONCE
      ath9k: Check if the STA supports HT when initializing rate contro=
l
      mac80211: Re-enable aggregation

Tim Gardner (1):
      ipw2x00: change default policy for auto-associate

Tomas Winkler (15):
      iwlwifi: make initial calibration set configurable
      iwlwifi: take a valid antenna upon rate scale init
      iwlwifi: refactor rxon time command
      iwlwifi: remove host commands structures from iwl_cmd
      iwlwifi: add iwl_cmd_queue_free for readability
      iwlwifi: unify tx antenna toggling
      iwlwifi: fix TX cmd dma unmapping
      iwlwifi: tx command must run on same tfd as packet
      iwlwifi: protect headers from double inclusion
      iwlwifi: refactor TX response flow
      iwlwifi: don't update TFD free counter for invalid station
      iwlwifi: parametrize eeprom versions
      iwlwifi: calibration command namespace renaming
      iwlwifi: refactor tx byte count table usage
      iwlwifi: run through spell checker

Wang Chen (1):
      airo: Kill directly reference of netdev->priv

Zhaolei (2):
      Fix debugfs_create_bool's error checking method for wireless/iwlw=
ifi/
      Fix debugfs_create_*'s error checking method for wireless/rt2x00/

colin-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org (1):
      Add nl80211 commands to get and set o11s mesh networking paramete=
rs

 Documentation/networking/README.ipw2200          |    2 +-
 Documentation/networking/regulatory.txt          |   22 +-
 Documentation/rfkill.txt                         |   20 +-
 MAINTAINERS                                      |    2 +-
 drivers/net/wireless/Kconfig                     |    1 +
 drivers/net/wireless/adm8211.c                   |   24 +-
 drivers/net/wireless/airo.c                      |  171 +++---
 drivers/net/wireless/ath5k/ath5k.h               |   86 ++-
 drivers/net/wireless/ath5k/base.c                |  119 ++--
 drivers/net/wireless/ath5k/dma.c                 |  190 +++++--
 drivers/net/wireless/ath5k/initvals.c            |    8 +-
 drivers/net/wireless/ath5k/phy.c                 |    5 +-
 drivers/net/wireless/ath5k/qcu.c                 |   37 +-
 drivers/net/wireless/ath5k/reg.h                 |    3 +-
 drivers/net/wireless/ath5k/reset.c               |    3 +-
 drivers/net/wireless/ath9k/ath9k.h               |   13 +
 drivers/net/wireless/ath9k/core.h                |   10 +-
 drivers/net/wireless/ath9k/hw.c                  |    5 +-
 drivers/net/wireless/ath9k/main.c                |  123 ++--
 drivers/net/wireless/ath9k/rc.c                  |   58 +-
 drivers/net/wireless/ath9k/rc.h                  |    1 -
 drivers/net/wireless/ath9k/recv.c                |    5 +-
 drivers/net/wireless/ath9k/xmit.c                |   84 ++--
 drivers/net/wireless/b43/dma.c                   |    4 +-
 drivers/net/wireless/b43/main.c                  |   90 +--
 drivers/net/wireless/b43/pio.c                   |    3 +-
 drivers/net/wireless/b43/xmit.c                  |   60 ++-
 drivers/net/wireless/b43/xmit.h                  |    5 +-
 drivers/net/wireless/b43legacy/dma.c             |   46 +-
 drivers/net/wireless/b43legacy/main.c            |   76 +--
 drivers/net/wireless/b43legacy/pio.c             |   31 +-
 drivers/net/wireless/b43legacy/xmit.c            |   26 +-
 drivers/net/wireless/b43legacy/xmit.h            |    2 +-
 drivers/net/wireless/hostap/hostap_common.h      |   13 -
 drivers/net/wireless/hostap/hostap_wlan.h        |    2 +-
 drivers/net/wireless/ipw2100.c                   |   24 +-
 drivers/net/wireless/ipw2200.c                   |  204 +++---
 drivers/net/wireless/ipw2200.h                   |    1 +
 drivers/net/wireless/iwlwifi/Kconfig             |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-io.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |   71 +--
 drivers/net/wireless/iwlwifi/iwl-3945.c          |   69 ++-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |  148 ++---
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  136 ++---
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h       |   39 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c          |  272 ++++----
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c        |   80 +--
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c           |  125 ++--
 drivers/net/wireless/iwlwifi/iwl-calib.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h      |  191 +++---
 drivers/net/wireless/iwlwifi/iwl-core.c          |  186 ++++---
 drivers/net/wireless/iwlwifi/iwl-core.h          |   15 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h           |   60 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h            |    8 +
 drivers/net/wireless/iwlwifi/iwl-helpers.h       |  107 ----
 drivers/net/wireless/iwlwifi/iwl-io.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c         |   18 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c          |  131 ++---
 drivers/net/wireless/iwlwifi/iwl-sta.c           |   60 ++-
 drivers/net/wireless/iwlwifi/iwl-tx.c            |  340 ++++++-----
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |  100 +---
 drivers/net/wireless/libertas/assoc.c            |   19 +-
 drivers/net/wireless/libertas/cmd.c              |    4 +-
 drivers/net/wireless/libertas/debugfs.c          |    5 +-
 drivers/net/wireless/libertas/decl.h             |    4 -
 drivers/net/wireless/libertas/main.c             |   27 -
 drivers/net/wireless/libertas/scan.c             |   15 +-
 drivers/net/wireless/libertas/wext.c             |    4 +-
 drivers/net/wireless/libertas_tf/main.c          |    8 +-
 drivers/net/wireless/mac80211_hwsim.c            |   39 +-
 drivers/net/wireless/orinoco.c                   |   39 +-
 drivers/net/wireless/orinoco.h                   |    5 +
 drivers/net/wireless/p54/p54.h                   |   51 +-
 drivers/net/wireless/p54/p54common.c             |  737 +++++++++++++-=
--------
 drivers/net/wireless/p54/p54common.h             |  287 +++++++--
 drivers/net/wireless/p54/p54pci.c                |   23 +-
 drivers/net/wireless/p54/p54usb.c                |   74 ++-
 drivers/net/wireless/rt2x00/rt2400pci.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |    5 +-
 drivers/net/wireless/rt2x00/rt2x00config.c       |   20 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c        |   25 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |   22 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |   26 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c        |   24 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h        |    9 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |    4 +-
 drivers/net/wireless/rtl8180_dev.c               |   31 +-
 drivers/net/wireless/rtl8187.h                   |    1 -
 drivers/net/wireless/rtl8187_dev.c               |  123 +++--
 drivers/net/wireless/rtl8187_rtl8225.c           |    8 -
 drivers/net/wireless/zd1211rw/zd_mac.c           |   38 +-
 drivers/net/wireless/zd1211rw/zd_usb.c           |    2 +-
 include/linux/ieee80211.h                        |  142 +++--
 include/linux/nl80211.h                          |   98 +++
 include/linux/skbuff.h                           |    4 +
 include/net/cfg80211.h                           |   32 +-
 include/net/ieee80211.h                          |  133 +----
 include/net/lib80211.h                           |   18 +
 include/net/mac80211.h                           |  414 +++++++-----
 include/net/wireless.h                           |   58 +--
 net/core/skbuff.c                                |    1 +
 net/ieee80211/Kconfig                            |   57 +--
 net/ieee80211/ieee80211_module.c                 |   26 -
 net/ieee80211/ieee80211_rx.c                     |   45 +-
 net/ieee80211/ieee80211_wx.c                     |   21 +-
 net/mac80211/cfg.c                               |   96 +++-
 net/mac80211/debugfs.c                           |   12 +-
 net/mac80211/debugfs_netdev.c                    |  114 +---
 net/mac80211/debugfs_sta.c                       |   79 +---
 net/mac80211/ht.c                                |  200 +++++--
 net/mac80211/ieee80211_i.h                       |   59 +--
 net/mac80211/iface.c                             |   27 +-
 net/mac80211/main.c                              |  209 +++----
 net/mac80211/mesh.c                              |    2 +-
 net/mac80211/mesh_hwmp.c                         |    6 +-
 net/mac80211/mlme.c                              |  343 ++++++-----
 net/mac80211/rate.c                              |   52 +-
 net/mac80211/rate.h                              |   11 +-
 net/mac80211/rc80211_minstrel.c                  |  107 ++--
 net/mac80211/rc80211_minstrel.h                  |    2 +
 net/mac80211/rc80211_pid.h                       |    3 +-
 net/mac80211/rc80211_pid_algo.c                  |   32 +-
 net/mac80211/rc80211_pid_debugfs.c               |    5 +-
 net/mac80211/rx.c                                |   39 +-
 net/mac80211/scan.c                              |   22 +-
 net/mac80211/sta_info.c                          |    4 +-
 net/mac80211/sta_info.h                          |   42 +-
 net/mac80211/tx.c                                |  414 ++++++------
 net/mac80211/util.c                              |   20 +-
 net/mac80211/wep.c                               |   26 +-
 net/mac80211/wep.h                               |    2 +-
 net/mac80211/wext.c                              |   72 +--
 net/mac80211/wme.c                               |   24 +-
 net/mac80211/wpa.c                               |   29 +-
 net/rfkill/rfkill-input.c                        |  337 ++++++++---
 net/rfkill/rfkill-input.h                        |    3 +
 net/rfkill/rfkill.c                              |   80 +++-
 net/wireless/Kconfig                             |   10 +
 net/wireless/Makefile                            |    1 +
 net/wireless/core.c                              |    6 +-
 net/wireless/lib80211.c                          |   65 ++
 net/wireless/nl80211.c                           |  213 ++++++-
 net/wireless/reg.c                               |  290 +++------
 net/wireless/reg.h                               |   20 +-
 158 files changed, 5287 insertions(+), 4359 deletions(-)
 create mode 100644 include/net/lib80211.h
 create mode 100644 net/wireless/lib80211.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2008-10-31.patch.bz2

--=20
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
