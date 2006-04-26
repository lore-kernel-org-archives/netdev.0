From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev tree updated
Date: Wed, 26 Apr 2006 16:20:09 -0400
Message-ID: <20060426202004.GD7922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:35089 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964857AbWDZUUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 16:20:21 -0400
Received: from bilbo.hq.tuxdriver.com (azure.tuxdriver.com [24.172.12.5])
	by ra.tuxdriver.com (8.13.6/8.13.6) with ESMTP id k3QKKA3f028231
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 16:20:10 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k3QKKAq6018963
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 16:20:10 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k3QKK9WQ018941
	for netdev@vger.kernel.org; Wed, 26 Apr 2006 16:20:09 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I know y'all were wondering if I was ever going to merge wireless-dev
patches...I apologize for the delay. :-)

Please recall that I have collapsed the branching, and now all the
Devicescape-based stuff is on the master branch here:

	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

I also have the individual patches extracted and available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-dev/

The rt2x00 driver is currently broken in this tree, thanks to one of
Jiri's d80211 patches.	Hopefully Jiri or someone else will submit
a patch to fix that soon.

This also includes a patch from Jouni to move the d80211-based drivers
to the drivers/net/wireless/d80211 directory...FYI.

We are working towards getting this tree ready to feed the -mm tree.
This means that I am accepting patches which address cleanups, compile
problems, and kernel coding style issues (as well as functional
changes).  I am also happy to accept patches for new drivers or for
porting ieee80211+softmac-based drivers to the d80211 stack.

There was a surprising amount of agreement that we should be marching
toward the use of the Devicescape stack.  That means that this tree
is the future.	Let's get it whipped into shape!

Thanks,

John

---

The following changes since commit ebce6da892686429b8f2bdb152288ca22f4db58f:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Adrian Bunk:
      bcm43xx: fix dyn tssi2dbm memleak

Jiri Benc:
      d80211: symlinks to wiphy in sysfs
      d80211: allow WDS remote to by set by WE
      d80211: add IBSS and monitor interface types
      d80211: non-shared interface types
      d80211: remove local->bssid variable
      d80211: rename IEEE80211_SUB_IF_TYPE_ constants
      d80211: ask driver for allowed iface combinations
      d80211: remove obsolete stuff
      d80211: fix interface configuration
      d80211: rename adm_status to radio_enabled
      d80211: interface types changeable by SIOCSIWMODE
      d80211: master interface auto up/down
      d80211: set_multicast_list
      d80211: fix handling of received frames
      d80211: fix monitor interfaces
      d80211: fix AP interfaces
      d80211: fix SIOCGIWESSID ioctl
      d80211: use is_multicast_ether_addr
      d80211: fix Oops caused by packets sent directly to master device
      d80211: don't use pointer in ieee80211_tx_control
      d80211: per-interface SSID
      d80211: per-interface generic_elem
      d80211: get rid of default AP interface
      d80211: rename master interface
      d80211: add one default interface
      bcm43xx: fix breakage from d80211 patches

Jouni Malinen:
      Move d80211-based drivers into new subdirectory
      d80211: Replace MODULE_PARM with module_param

Michael Buesch:
      bcm43xx-d80211: use pci_iomap() for convenience.
      bcm43xx-d80211: protect tx_stat callback from uninitialized device
      bcm43xx: fix pctl slowclock limit calculation
      bcm43xx: sysfs code cleanup

 drivers/net/wireless/Kconfig                       |    3 
 drivers/net/wireless/Makefile                      |    6 
 .../net/wireless/bcm43xx-d80211/bcm43xx_sysfs.h    |   25 
 drivers/net/wireless/d80211/Kconfig                |    2 
 drivers/net/wireless/d80211/Makefile               |    2 
 drivers/net/wireless/d80211/README                 |    2 
 drivers/net/wireless/d80211/bcm43xx/Kconfig        |    0 
 drivers/net/wireless/d80211/bcm43xx/Makefile       |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |   19 
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c  |    2 
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h  |    0 
 .../net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c  |    0 
 .../net/wireless/d80211/bcm43xx/bcm43xx_ethtool.h  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.c  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ilt.h  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.h |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   87 +
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c  |    1 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.h  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h  |    0 
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.c    |  115 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_power.h    |    9 
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.c    |    0 
 .../net/wireless/d80211/bcm43xx/bcm43xx_radio.h    |    0 
 .../net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c    |  115 +-
 .../net/wireless/d80211/bcm43xx/bcm43xx_sysfs.h    |    9 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |    0 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.h |    0 
 drivers/net/wireless/d80211/rt2x00/Kconfig         |    0 
 drivers/net/wireless/d80211/rt2x00/Makefile        |    0 
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    0 
 drivers/net/wireless/d80211/rt2x00/rt2x00.h        |    0 
 include/net/d80211.h                               |  212 ++-
 net/d80211/Makefile                                |    1 
 net/d80211/hostapd_ioctl.h                         |    3 
 net/d80211/ieee80211.c                             | 1519 +++++++-------------
 net/d80211/ieee80211_dev.c                         |   16 
 net/d80211/ieee80211_i.h                           |   82 +
 net/d80211/ieee80211_iface.c                       |  303 ++++
 net/d80211/ieee80211_ioctl.c                       |  443 +++---
 net/d80211/ieee80211_proc.c                        |   40 -
 net/d80211/ieee80211_sta.c                         |   75 +
 net/d80211/ieee80211_sysfs.c                       |   88 +
 net/d80211/wme.c                                   |    2 
 54 files changed, 1660 insertions(+), 1521 deletions(-)
 delete mode 100644 drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysfs.h
 create mode 100644 drivers/net/wireless/d80211/Kconfig
 create mode 100644 drivers/net/wireless/d80211/Makefile
 create mode 100644 drivers/net/wireless/d80211/README
 rename drivers/net/wireless/{bcm43xx-d80211/Kconfig => d80211/bcm43xx/Kconfig} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/Makefile => d80211/bcm43xx/Makefile} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx.h => d80211/bcm43xx/bcm43xx.h} (99%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_debugfs.c => d80211/bcm43xx/bcm43xx_debugfs.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_debugfs.h => d80211/bcm43xx/bcm43xx_debugfs.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_dma.c => d80211/bcm43xx/bcm43xx_dma.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_dma.h => d80211/bcm43xx/bcm43xx_dma.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_ethtool.c => d80211/bcm43xx/bcm43xx_ethtool.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_ethtool.h => d80211/bcm43xx/bcm43xx_ethtool.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_ilt.c => d80211/bcm43xx/bcm43xx_ilt.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_ilt.h => d80211/bcm43xx/bcm43xx_ilt.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_leds.c => d80211/bcm43xx/bcm43xx_leds.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_leds.h => d80211/bcm43xx/bcm43xx_leds.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_main.c => d80211/bcm43xx/bcm43xx_main.c} (99%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_main.h => d80211/bcm43xx/bcm43xx_main.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_phy.c => d80211/bcm43xx/bcm43xx_phy.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_phy.h => d80211/bcm43xx/bcm43xx_phy.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_pio.c => d80211/bcm43xx/bcm43xx_pio.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_pio.h => d80211/bcm43xx/bcm43xx_pio.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_power.c => d80211/bcm43xx/bcm43xx_power.c} (82%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_power.h => d80211/bcm43xx/bcm43xx_power.h} (88%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_radio.c => d80211/bcm43xx/bcm43xx_radio.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_radio.h => d80211/bcm43xx/bcm43xx_radio.h} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_sysfs.c => d80211/bcm43xx/bcm43xx_sysfs.c} (67%)
 create mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.h
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_xmit.c => d80211/bcm43xx/bcm43xx_xmit.c} (100%)
 rename drivers/net/wireless/{bcm43xx-d80211/bcm43xx_xmit.h => d80211/bcm43xx/bcm43xx_xmit.h} (100%)
 rename drivers/net/wireless/{rt2x00/Kconfig => d80211/rt2x00/Kconfig} (100%)
 rename drivers/net/wireless/{rt2x00/Makefile => d80211/rt2x00/Makefile} (100%)
 rename drivers/net/wireless/{rt2x00/rt2400pci.c => d80211/rt2x00/rt2400pci.c} (100%)
 rename drivers/net/wireless/{rt2x00/rt2400pci.h => d80211/rt2x00/rt2400pci.h} (100%)
 rename drivers/net/wireless/{rt2x00/rt2500pci.c => d80211/rt2x00/rt2500pci.c} (100%)
 rename drivers/net/wireless/{rt2x00/rt2500pci.h => d80211/rt2x00/rt2500pci.h} (100%)
 rename drivers/net/wireless/{rt2x00/rt2500usb.c => d80211/rt2x00/rt2500usb.c} (100%)
 rename drivers/net/wireless/{rt2x00/rt2500usb.h => d80211/rt2x00/rt2500usb.h} (100%)
 rename drivers/net/wireless/{rt2x00/rt2x00.h => d80211/rt2x00/rt2x00.h} (100%)
 create mode 100644 net/d80211/ieee80211_iface.c
-- 
John W. Linville
linville@tuxdriver.com
