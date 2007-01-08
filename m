From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev updated (sync w/ 2.6.20-rc3 + lots of new stuff)
Date: Mon, 8 Jan 2007 16:54:51 -0500
Message-ID: <20070108215441.GF22498@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2293 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030188AbXAHWDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 17:03:00 -0500
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id l08M2bFw025660
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 17:02:43 -0500
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.13.7/8.13.6/Submit) with UUCP id l08M0cWF025582
	for netdev@vger.kernel.org; Mon, 8 Jan 2007 17:00:38 -0500
Received: from linville-t43.mobile (localhost [127.0.0.1] (may be forged))
	by linville-t43.mobile (8.13.8/8.13.8) with ESMTP id l08Lspwh032301
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 16:54:51 -0500
Received: (from linville@localhost)
	by linville-t43.mobile (8.13.8/8.13.8/Submit) id l08Lsplq032300
	for netdev@vger.kernel.org; Mon, 8 Jan 2007 16:54:51 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Lots of wireless-dev activity around the holidays...still
catching-up...  I got stuff compiling, so I thought I'd push it out.

John

---

The following changes since commit 3622152cf1ed4613addde30bce9cd9f71d17efa2:
  John W. Linville (1):
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

David Kimdon (9):
      d80211: allow for hardware crypto of default keys
      d80211: set default_wep_only dynamically
      d80211: fix potential interface name overflow
      d80211: fix potential invalid array index returning key information
      d80211: remove unused references to sub interface data
      d80211: fix invalid check for sub interface type AP
      d80211: do not pass an invalid key index to set_key()
      d80211: clear ifsta->associated flag when authentication starts
      d80211: inhibit duplicate authentication requests when setting bssid

Jan Kiszka (1):
      d80211: Reinit keys on mode change

Jiri Benc (5):
      Merge branch 'from-john'
      d80211: simplify classify_1d
      d80211: small documentation fix
      d80211: do not cancel uninitialized work
      rt2x00: fix breakage after pkt_type field was removed

Johannes Berg (3):
      d80211: add missing \n in skb queue warning
      fix some wireless ext stuff
      fix cfg80211 WE compat code

John W. Linville (8):
      Merge branch 'up' of git://git.kernel.org/.../jbenc/dscape
      Merge branch 'adm8211-week51' of git://git.kernel.org/.../mwu/d80211-drivers
      Merge branch 'p54-week51' of git://git.kernel.org/.../mwu/d80211-drivers
      Merge branch 'zd1211rw-week51' of git://git.kernel.org/.../mwu/d80211-drivers
      Merge branch 'up2' of git://git.kernel.org/.../jbenc/dscape
      cfg80211: fix build breakage from genlmsg_put signature change
      bcm43xx, rt2x00: fix build breakage from INIT_DELAYED_WORK changes
      zd1211rw-d80211: port INIT_DELAYED_WORK changes from mainline

Michael Buesch (7):
      d80211: Fix errorcode in ieee80211_update_hw
      d80211: Fix passing of invalid pointer
      d80211: Fix 64bit printk warnings
      d80211: Turn PHYmode list from an array into a linked list
      d80211: constify ieee80211_ops pointer
      bcm43xx-d80211: Fix for PHYmode API change.
      rt2x00: Fix compilation for d80211 hwmode API change

Michael Wu (31):
      d80211: remove pkt_type/pkt_probe_resp
      d80211: move 802.11 defines to linux/ieee80211.h
      d80211: merge d80211_shared.h into d80211.h
      d80211: merge d80211_mgmt.h into linux/ieee80211.h
      d80211: move d80211_common.h to net/d80211
      zd1211rw-d80211: Fix of a locking bug
      zd1211rw-d80211: Revert "zd1211rw: Removed unneeded packed attributes"
      zd1211rw-d80211: Add 3 more device IDs
      zd1211rw-d80211: Add ID for ZyXEL G-220
      zd1211rw-d80211: Add ID for Planex GW-US54Mini
      zd1211rw-d80211: Add ID for Belkin F5D7050 v4000
      zd1211rw-d80211: cleanups
      zd1211rw-d80211: Optimized handling of zero length entries in length info
      zd1211rw-d80211: check IEEE80211_TXCTL_USE_CTS_PROTECT
      zd1211rw-d80211: Use ieee80211_tx_status
      p54: fix device memory allocator
      p54: fix TX of encrypted frames
      p54: remove unnecessary use of __constant_cpu_to_*
      p54: use hardware RX frequency reporting
      p54: use link LED
      p54: fix issues found by sparse
      p54: set phymode in RX
      zd1211rw-d80211: 2 new ZD1211B device ID's
      zd1211rw-d80211: Add ID for Linksys WUSBF54G
      adm8211: set phymode in RX
      d80211: fix wep.c breakage
      d80211: fix wme.c breakage
      d80211: fix workqueue breakage
      adm8211: Fix compilation for d80211 hwmode API change
      p54: Fix compilation for d80211 hwmode API change
      zd1211rw-d80211: Fix compilation for d80211 hwmode API change

Mohamed Abbas (1):
      d80211: add mising sta_info_put function

Zhu Yi (1):
      d80211: fix classify_1d() priority selection

 drivers/net/wireless/d80211/adm8211/adm8211.c      |    9 +-
 drivers/net/wireless/d80211/adm8211/adm8211.h      |    2 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h      |    6 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   68 +++--
 drivers/net/wireless/d80211/p54/prism54.h          |    3 +-
 drivers/net/wireless/d80211/p54/prism54common.c    |  123 +++++---
 drivers/net/wireless/d80211/p54/prism54common.h    |   15 +-
 drivers/net/wireless/d80211/p54/prism54pci.c       |   65 ++--
 drivers/net/wireless/d80211/p54/prism54usb.c       |  105 ++++----
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |  130 +++++----
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |    6 +-
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |  170 ++++++-----
 drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |    6 +-
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |  170 ++++++-----
 drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    6 +-
 drivers/net/wireless/d80211/rt2x00/rt2x00.h        |   14 +-
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |  170 ++++++-----
 drivers/net/wireless/d80211/rt2x00/rt61pci.h       |    6 +-
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |  170 ++++++-----
 drivers/net/wireless/d80211/rt2x00/rt73usb.h       |    6 +-
 drivers/net/wireless/d80211/zd1211rw/zd_chip.h     |   83 +++---
 drivers/net/wireless/d80211/zd1211rw/zd_def.h      |    1 +
 .../net/wireless/d80211/zd1211rw/zd_ieee80211.h    |    2 +-
 drivers/net/wireless/d80211/zd1211rw/zd_mac.c      |  191 +++++++-----
 drivers/net/wireless/d80211/zd1211rw/zd_mac.h      |   10 +-
 drivers/net/wireless/d80211/zd1211rw/zd_usb.c      |   56 ++--
 drivers/net/wireless/d80211/zd1211rw/zd_usb.h      |   14 +-
 include/linux/Kbuild                               |    1 +
 include/linux/ieee80211.h                          |  315 ++++++++++++++++++++
 include/net/d80211.h                               |  154 +++-------
 include/net/d80211_common.h                        |   98 ------
 include/net/d80211_mgmt.h                          |  223 --------------
 include/net/d80211_shared.h                        |   46 ---
 net/core/net-sysfs.c                               |    4 +-
 net/d80211/Kconfig                                 |    1 +
 net/d80211/ieee80211.c                             |  110 +++----
 net/d80211/ieee80211_common.h                      |   98 ++++++
 net/d80211/ieee80211_i.h                           |   21 +-
 net/d80211/ieee80211_iface.c                       |   18 +-
 net/d80211/ieee80211_ioctl.c                       |  120 +++++---
 net/d80211/ieee80211_scan.c                        |   83 +++---
 net/d80211/ieee80211_sta.c                         |   99 ++++---
 net/d80211/ieee80211_sysfs.c                       |   10 +-
 net/d80211/sta_info.c                              |    7 +-
 net/d80211/wep.c                                   |    1 +
 net/d80211/wme.c                                   |   24 +--
 net/d80211/wpa.c                                   |    2 +-
 net/wireless/Makefile                              |    2 +-
 net/wireless/core.c                                |    2 +-
 net/wireless/nl80211.c                             |    3 +-
 50 files changed, 1604 insertions(+), 1445 deletions(-)
 create mode 100644 include/linux/ieee80211.h
 delete mode 100644 include/net/d80211_common.h
 delete mode 100644 include/net/d80211_mgmt.h
 delete mode 100644 include/net/d80211_shared.h
 create mode 100644 net/d80211/ieee80211_common.h

Comprehensive diff attached as wireless-dev-2007-01-08.patch.bz2 due to
size constraints.
-- 
John W. Linville
linville@tuxdriver.com

--BOKacYhQ+x31HxR3
Content-Type: application/x-bzip2
Content-Disposition: attachment; filename="wireless-dev-2007-01-08.patch.bz2"
Content-Transfer-Encoding: base64

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

--BOKacYhQ+x31HxR3--
