From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev updated -- 28 November 2006
Date: Tue, 28 Nov 2006 19:53:20 -0500
Message-ID: <20061129005313.GB3428@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:56590 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1758671AbWK2B3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 20:29:03 -0500
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id kAT1SquC001922
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 20:28:58 -0500
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.13.7/8.13.6/Submit) with UUCP id kAT0xuDL001525
	for netdev@vger.kernel.org; Tue, 28 Nov 2006 19:59:56 -0500
Received: from linville-t43.mobile (linville-t43.mobile [127.0.0.1])
	by linville-t43.mobile (8.13.8/8.13.8) with ESMTP id kAT0rMbp017430
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 19:53:22 -0500
Received: (from linville@localhost)
	by linville-t43.mobile (8.13.8/8.13.8/Submit) id kAT0rLqY017379
	for netdev@vger.kernel.org; Tue, 28 Nov 2006 19:53:21 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This update gets most of the drivers building again, with the notable
exception of the rt2x00 drivers...  There are lots of updates from
Michael Wu to the p54 driver as well.  Also, a patch from Michael
Buesch that fixes a hwcrypto issue, but incidentally drops support
for rev 3 firmware from the d80211-based bcm43xx driver.

d80211 users and (especially) stack and driver developers, please pull.

---

The following changes since commit 2852c59403e4686eb868db81e9ad3d18f0d73f08:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Ivo van Doorn:
      d80211: Reset assoc and auth retry counters

Johannes Berg:
      bcm43xx: update to new d80211 driver API

Michael Buesch:
      bcm43xx-d80211: fix hwcrypto issues (mcast)

Michael Wu:
      p54: Set dummy maxssi to prevent a divide by zero.
      p54: Add PCI driver
      p54: Add license boilerplate
      p54: Move eeprom readback packet filling code to common
      Update MAINTAINERS entries for wireless drivers
      adm8211: Reduce delays
      adm8211: Convert to new API
      p54: Convert to new API
      p54: Add support for net2280 based USB devices
      p54: Adjust/add printks in PCI driver

 MAINTAINERS                                        |   20 -
 drivers/net/wireless/d80211/adm8211/adm8211.c      |  336 +++++-----
 drivers/net/wireless/d80211/adm8211/adm8211.h      |    1 
 drivers/net/wireless/d80211/bcm43xx/Makefile       |    2 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |   14 
 .../net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c  |    4 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |    7 
 .../net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c  |   51 --
 .../net/wireless/d80211/bcm43xx/bcm43xx_ethtool.h  |    8 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |  422 ++++++------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |    2 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |   56 +-
 drivers/net/wireless/d80211/p54/Kconfig            |    3 
 drivers/net/wireless/d80211/p54/Makefile           |    1 
 drivers/net/wireless/d80211/p54/net2280.h          |  452 +++++++++++++
 drivers/net/wireless/d80211/p54/prism54.h          |   42 +
 drivers/net/wireless/d80211/p54/prism54common.c    |  252 +++++--
 drivers/net/wireless/d80211/p54/prism54common.h    |   19 +
 drivers/net/wireless/d80211/p54/prism54magic.h     |   53 ++
 drivers/net/wireless/d80211/p54/prism54pci.c       |  697 ++++++++++++++++++++
 drivers/net/wireless/d80211/p54/prism54pci.h       |  106 +++
 drivers/net/wireless/d80211/p54/prism54usb.c       |  560 +++++++++++++---
 drivers/net/wireless/d80211/p54/prism54usb.h       |   92 +++
 net/d80211/ieee80211_sta.c                         |    2 
 24 files changed, 2505 insertions(+), 697 deletions(-)
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c
 delete mode 100644 drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.h
 create mode 100644 drivers/net/wireless/d80211/p54/net2280.h
 create mode 100644 drivers/net/wireless/d80211/p54/prism54pci.c
 create mode 100644 drivers/net/wireless/d80211/p54/prism54pci.h

-- 
John W. Linville
linville@tuxdriver.com
