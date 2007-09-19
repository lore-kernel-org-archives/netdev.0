From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 14:10:05 -0400
Message-ID: <20070919181005.GB5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff & Dave,

This patch adds z1211 (previously known as zd1211rw-mac80211),
a driver for Zydas ZD1211 hardware.  This driver has proven very
robust -- Fedora 7 uses this driver and I don't think I have any open
bugzillas for it.  Either the driver works well, or no one as using
it...given the common availability of the hardware, I have to presume
the former. :-)

This driver is mostly a port of zd1211rw to the mac80211
infrastructure.  In fact, most zd1211rw patches have been mirrored
directly to this driver for some time.  I considered merely updating
the existing driver with this code, but I think it is more prudent to
include this as a separate driver just to avoid confusion.  There is
some symbol clash between the two drivers, so I add a Kconfig hack
to ensure that only one or the other is built-in or that this one is
built as a module.

The maintainers have identified some (IMHO minor) issues with the
mac80211 port of this driver.  Some of them are summarized here:

	http://linuxwireless.org/en/users/Drivers/zd1211rw/mac80211Issues

Still, I think we would be better-off having this driver upstream.

Thanks,

John

---

Patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/0001-z1211-add-mac80211-based-driver-for-ZD1211-hardwa.patch

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git z1211

Daniel Drake (1):
      z1211: add mac80211-based driver for ZD1211 hardware

 MAINTAINERS                                |   10 +
 drivers/net/wireless/Kconfig               |    1 +
 drivers/net/wireless/Makefile              |    1 +
 drivers/net/wireless/z1211/Kconfig         |   18 +
 drivers/net/wireless/z1211/Makefile        |   10 +
 drivers/net/wireless/z1211/zd_chip.c       | 1619 ++++++++++++++++++++++++++++
 drivers/net/wireless/z1211/zd_chip.h       |  921 ++++++++++++++++
 drivers/net/wireless/z1211/zd_def.h        |   57 +
 drivers/net/wireless/z1211/zd_ieee80211.c  |  100 ++
 drivers/net/wireless/z1211/zd_ieee80211.h  |   75 ++
 drivers/net/wireless/z1211/zd_mac.c        |  949 ++++++++++++++++
 drivers/net/wireless/z1211/zd_mac.h        |  227 ++++
 drivers/net/wireless/z1211/zd_rf.c         |  178 +++
 drivers/net/wireless/z1211/zd_rf.h         |  108 ++
 drivers/net/wireless/z1211/zd_rf_al2230.c  |  439 ++++++++
 drivers/net/wireless/z1211/zd_rf_al7230b.c |  492 +++++++++
 drivers/net/wireless/z1211/zd_rf_rf2959.c  |  279 +++++
 drivers/net/wireless/z1211/zd_rf_uw2453.c  |  534 +++++++++
 drivers/net/wireless/z1211/zd_usb.c        | 1528 ++++++++++++++++++++++++++
 drivers/net/wireless/z1211/zd_usb.h        |  263 +++++
 drivers/net/wireless/z1211/zd_util.c       |   82 ++
 drivers/net/wireless/z1211/zd_util.h       |   29 +
 22 files changed, 7920 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wireless/z1211/Kconfig
 create mode 100644 drivers/net/wireless/z1211/Makefile
 create mode 100644 drivers/net/wireless/z1211/zd_chip.c
 create mode 100644 drivers/net/wireless/z1211/zd_chip.h
 create mode 100644 drivers/net/wireless/z1211/zd_def.h
 create mode 100644 drivers/net/wireless/z1211/zd_ieee80211.c
 create mode 100644 drivers/net/wireless/z1211/zd_ieee80211.h
 create mode 100644 drivers/net/wireless/z1211/zd_mac.c
 create mode 100644 drivers/net/wireless/z1211/zd_mac.h
 create mode 100644 drivers/net/wireless/z1211/zd_rf.c
 create mode 100644 drivers/net/wireless/z1211/zd_rf.h
 create mode 100644 drivers/net/wireless/z1211/zd_rf_al2230.c
 create mode 100644 drivers/net/wireless/z1211/zd_rf_al7230b.c
 create mode 100644 drivers/net/wireless/z1211/zd_rf_rf2959.c
 create mode 100644 drivers/net/wireless/z1211/zd_rf_uw2453.c
 create mode 100644 drivers/net/wireless/z1211/zd_usb.c
 create mode 100644 drivers/net/wireless/z1211/zd_usb.h
 create mode 100644 drivers/net/wireless/z1211/zd_util.c
 create mode 100644 drivers/net/wireless/z1211/zd_util.h
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
