From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-davem' branch of wireless-2.6 (for 2.6.24)
Date: Sat, 22 Sep 2007 15:54:57 -0400
Message-ID: <20070922195457.GA22629@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2537 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435AbXIVUID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 16:08:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff & Dave,

Another round of miscellaneous driver and stack fixes intended for
2.6.24...

The tree is based on the latest net-2.6.24 as of this morning.
I've included a 'master-davem' branch in my tree as a reference in
case net-2.6.24 gets rebased again in the meantime.

Thanks!

John

---

The individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem/

---

The following changes since commit 42765047105fdd496976bc1784d22eec1cd9b9aa:
  David S. Miller (1):
        [MAC80211]: Fix mixed declarations and code in ap_sta_ps_start().

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Andrew Morton (1):
      p54pci: terminate pci table

Jesper Juhl (1):
      zd1211rw: Don't needlessly initialize variable to NULL in zd_chip

Johannes Berg (11):
      fix softmac lockdep reports
      mac80211: allow drivers to indicate failed FCS/PLCP checksum
      mac80211: remove key threshold stuff
      mac80211: remove IEEE80211_CONF_SSID_HIDDEN
      mac80211: yet more documentation
      mac80211: fix warnings introduced by the doc patches
      mac80211: remove tx info sw_retry_attempt member
      mac80211: print out wiphy name instead of master device
      mac80211: rename ieee80211_cfg.c to cfg.c
      mac80211: kill IE parse typedef
      mac80211: kill vlan_id

Larry Finger (3):
      bcm43xx: Change radio hardware switch status printk from debug to regular
      b43legacy: Support for turning the radio off from software.
      b43legacy: Change the hardware radio enable logic and cleanup code

Michael Buesch (7):
      b43: Don't lock irq_lock in debugfs txpower adjust
      ssb: Use ioreadX() and iowriteX() for PCI.
      ssb: Sparse fixes.
      b43: Change loglevel of radio-enable message.
      mac80211: Add support for setting TX power and radio status
      b43: Remove the "radio hw enabled" message on startup.
      b43: Support for turning the radio off from software.

Michael Wu (1):
      mac80211: rename ieee80211_cfg.h to cfg.h

Ryan Mallon (2):
      libertas: set dnld_sent correctly for CF parts
      libertas: fix interrupts in CF driver

Ulrich Kunitz (1):
      zd1211rw: add USB id for Telegent TG54USB WLAN adapter

Vladimir Davydov (2):
      libertas: fix oops on the blackfin architecture
      libertas: fix oops on the blackfin architecture

Zhu Yi (2):
      iwlwifi: remove per-file CFLAGS for IWL define
      iwlwifi: create own directory for iwlwifi driver

 drivers/net/wireless/Kconfig                      |  130 +-------------
 drivers/net/wireless/Makefile                     |   12 +-
 drivers/net/wireless/b43/b43.h                    |   11 +-
 drivers/net/wireless/b43/debugfs.c                |   19 +--
 drivers/net/wireless/b43/leds.c                   |   15 +-
 drivers/net/wireless/b43/main.c                   |   44 ++++-
 drivers/net/wireless/b43/main.h                   |   17 --
 drivers/net/wireless/b43/phy.c                    |   48 ++++--
 drivers/net/wireless/b43legacy/b43legacy.h        |   11 +-
 drivers/net/wireless/b43legacy/leds.c             |   12 +-
 drivers/net/wireless/b43legacy/main.c             |   41 ++++-
 drivers/net/wireless/b43legacy/main.h             |   20 --
 drivers/net/wireless/b43legacy/phy.c              |   14 +--
 drivers/net/wireless/b43legacy/radio.c            |   41 ++++-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c       |    4 +-
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c      |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig              |  128 +++++++++++++
 drivers/net/wireless/iwlwifi/Makefile             |    5 +
 drivers/net/wireless/{ => iwlwifi}/iwl-3945-hw.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-3945-rs.c  |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwl-3945-rs.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-3945.c     |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwl-3945.h     |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-4965-hw.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-4965-rs.c  |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwl-4965-rs.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-4965.c     |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwl-4965.h     |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-channel.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-commands.h |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-debug.h    |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-eeprom.h   |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-helpers.h  |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-hw.h       |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-io.h       |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-priv.h     |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-prph.h     |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl-spectrum.h |    0 
 drivers/net/wireless/{ => iwlwifi}/iwl3945-base.c |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwl4965-base.c |    2 +
 drivers/net/wireless/{ => iwlwifi}/iwlwifi.h      |    0 
 drivers/net/wireless/libertas/if_cs.c             |   42 +++--
 drivers/net/wireless/libertas/scan.c              |    8 +-
 drivers/net/wireless/p54pci.c                     |    1 +
 drivers/net/wireless/zd1211rw/zd_chip.c           |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c            |    1 +
 drivers/ssb/b43_pci_bridge.c                      |    2 +
 drivers/ssb/driver_chipcommon.c                   |    7 +-
 drivers/ssb/pci.c                                 |   18 +-
 include/net/ieee80211softmac.h                    |    2 +
 include/net/mac80211.h                            |  208 +++++++++++++++------
 net/ieee80211/softmac/ieee80211softmac_assoc.c    |    8 +-
 net/ieee80211/softmac/ieee80211softmac_auth.c     |    8 +-
 net/ieee80211/softmac/ieee80211softmac_event.c    |    2 +-
 net/ieee80211/softmac/ieee80211softmac_module.c   |   10 +-
 net/ieee80211/softmac/ieee80211softmac_scan.c     |    4 +-
 net/ieee80211/softmac/ieee80211softmac_wx.c       |    8 +-
 net/mac80211/Makefile                             |    2 +-
 net/mac80211/{ieee80211_cfg.c => cfg.c}           |    2 +-
 net/mac80211/{ieee80211_cfg.h => cfg.h}           |    6 +-
 net/mac80211/debugfs.c                            |    4 -
 net/mac80211/debugfs_sta.c                        |    1 -
 net/mac80211/hostapd_ioctl.h                      |    1 -
 net/mac80211/ieee80211.c                          |   58 ++-----
 net/mac80211/ieee80211_common.h                   |    2 +-
 net/mac80211/ieee80211_i.h                        |    7 -
 net/mac80211/ieee80211_ioctl.c                    |   42 ++++-
 net/mac80211/ieee80211_rate.c                     |    4 +-
 net/mac80211/ieee80211_sta.c                      |    9 +-
 net/mac80211/rx.c                                 |   42 +++-
 net/mac80211/sta_info.c                           |    4 +-
 net/mac80211/sta_info.h                           |    2 -
 net/mac80211/tx.c                                 |   16 +-
 net/mac80211/util.c                               |    6 +
 74 files changed, 664 insertions(+), 461 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/Kconfig
 create mode 100644 drivers/net/wireless/iwlwifi/Makefile
 rename drivers/net/wireless/{ => iwlwifi}/iwl-3945-hw.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-3945-rs.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-3945-rs.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-3945.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-3945.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-4965-hw.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-4965-rs.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-4965-rs.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-4965.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-4965.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-channel.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-commands.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-debug.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-eeprom.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-helpers.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-hw.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-io.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-priv.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-prph.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl-spectrum.h (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl3945-base.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwl4965-base.c (100%)
 rename drivers/net/wireless/{ => iwlwifi}/iwlwifi.h (100%)
 rename net/mac80211/{ieee80211_cfg.c => cfg.c} (98%)
 rename net/mac80211/{ieee80211_cfg.h => cfg.h} (55%)
-- 
John W. Linville
linville@tuxdriver.com
