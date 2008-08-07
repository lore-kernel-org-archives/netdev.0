From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6#ath9k 2008-08-07
Date: Thu, 7 Aug 2008 10:38:34 -0400
Message-ID: <20080807143834.GB27762@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

I know we all want to see ath9k merged ASAP.  Since I'll be unavailable
this weekend, I have created a branch that includes Luis's revamped
list.h patches, the original ath9k patches, Adrian's ath9k gcc bug
work-around patch, and another cleanup series from Sujith on top.

Hopefully no further problems will reveal themselves with the list.h
stuff.  Please pull at your leisure, or if a problem arises I'll work to
resolve it on Monday.

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/ath9k/

---

The following changes since commit e6fce5b916cd7f7f79b2b3e53ba74bbfc1d7cf8b:
  Robert Olsson (1):
        pktgen: multiqueue etc.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git ath9k

Adrian Bunk (1):
      ath9k: work around gcc ICEs

Luis R. Rodriguez (4):
      list.h: Add list_splice_tail() and list_splice_tail_init()
      list.h: add list_cut_position()
      ath5k: remove Atheros 11n devices from supported list
      ath9k: Add new Atheros IEEE 802.11n driver

Sujith (6):
      ath9k: Cleanup data structures related to HW capabilities
      ath9k: Remove redundant data structure ath9k_txq_info
      ath9k: Use mac80211's band macros and remove enum hal_freq_band
      ath9k: Remove a few unused macros and fix indentation
      ath9k: More unused macros
      ath9k: Revamp wireless mode usage

 MAINTAINERS                              |    9 +
 drivers/dma/ioat_dma.c                   |    2 +-
 drivers/net/wireless/Kconfig             |    1 +
 drivers/net/wireless/Makefile            |    1 +
 drivers/net/wireless/ath5k/base.c        |    2 -
 drivers/net/wireless/ath9k/Kconfig       |    8 +
 drivers/net/wireless/ath9k/Makefile      |   11 +
 drivers/net/wireless/ath9k/ath9k.h       | 1021 ++++
 drivers/net/wireless/ath9k/beacon.c      |  979 ++++
 drivers/net/wireless/ath9k/core.c        | 1923 +++++++
 drivers/net/wireless/ath9k/core.h        | 1072 ++++
 drivers/net/wireless/ath9k/hw.c          | 8571 ++++++++++++++++++++++++++++++
 drivers/net/wireless/ath9k/hw.h          |  969 ++++
 drivers/net/wireless/ath9k/initvals.h    | 3146 +++++++++++
 drivers/net/wireless/ath9k/main.c        | 1470 +++++
 drivers/net/wireless/ath9k/phy.c         |  436 ++
 drivers/net/wireless/ath9k/phy.h         |  543 ++
 drivers/net/wireless/ath9k/rc.c          | 2126 ++++++++
 drivers/net/wireless/ath9k/rc.h          |  316 ++
 drivers/net/wireless/ath9k/recv.c        | 1318 +++++
 drivers/net/wireless/ath9k/reg.h         | 1385 +++++
 drivers/net/wireless/ath9k/regd.c        | 1026 ++++
 drivers/net/wireless/ath9k/regd.h        |  412 ++
 drivers/net/wireless/ath9k/regd_common.h | 1915 +++++++
 drivers/net/wireless/ath9k/xmit.c        | 2871 ++++++++++
 drivers/usb/host/ehci-q.c                |    2 +-
 include/linux/list.h                     |   87 +-
 27 files changed, 31609 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/Kconfig
 create mode 100644 drivers/net/wireless/ath9k/Makefile
 create mode 100644 drivers/net/wireless/ath9k/ath9k.h
 create mode 100644 drivers/net/wireless/ath9k/beacon.c
 create mode 100644 drivers/net/wireless/ath9k/core.c
 create mode 100644 drivers/net/wireless/ath9k/core.h
 create mode 100644 drivers/net/wireless/ath9k/hw.c
 create mode 100644 drivers/net/wireless/ath9k/hw.h
 create mode 100644 drivers/net/wireless/ath9k/initvals.h
 create mode 100644 drivers/net/wireless/ath9k/main.c
 create mode 100644 drivers/net/wireless/ath9k/phy.c
 create mode 100644 drivers/net/wireless/ath9k/phy.h
 create mode 100644 drivers/net/wireless/ath9k/rc.c
 create mode 100644 drivers/net/wireless/ath9k/rc.h
 create mode 100644 drivers/net/wireless/ath9k/recv.c
 create mode 100644 drivers/net/wireless/ath9k/reg.h
 create mode 100644 drivers/net/wireless/ath9k/regd.c
 create mode 100644 drivers/net/wireless/ath9k/regd.h
 create mode 100644 drivers/net/wireless/ath9k/regd_common.h
 create mode 100644 drivers/net/wireless/ath9k/xmit.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6-ath9k-2008-08-07.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
