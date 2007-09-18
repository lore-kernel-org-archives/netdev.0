From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'rt2x00' branch of wireless-2.6
Date: Tue, 18 Sep 2007 17:32:02 -0400
Message-ID: <20070918213202.GJ4940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff & Dave,

This patch adds the rt2x00 drivers for Ralink wireless hardware.
This collection of drivers has seen lots of action in Fedora (both
F7 and rawhide) and many people are using them with good results
(although some problems do remain).

Ivo in particular has been very helpful in responding to bug reports
for these drivers, including bugs reported at kernel.org and in
distro bugzillas.  I extend my thanks to him for both his past and
future support of these drivers.  I'm sure he and the rest of the
rt2x00 team will continue to support the community and their userbase.

Ivo and his team may feel I am jumping the gun a bit -- they have
a few more random bugs they wanted to squash before going upstream.
But since they are bugs, any fixes should still be able to be applied
in the -rc phase of 2.6.24.  In the meantime, I definitely think it
would be better to get this code into mainline rather than keeping
it out of stream.

Thanks,

John

---

Patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/rt2x00/0001-rt2x00-add-driver-for-Ralink-wireless-hardware.patch

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git rt2x00

Ivo van Doorn (1):
      rt2x00: add driver for Ralink wireless hardware

 CREDITS                                      |   31 +
 MAINTAINERS                                  |    8 +
 drivers/net/wireless/Kconfig                 |    1 +
 drivers/net/wireless/Makefile                |    2 +
 drivers/net/wireless/rt2x00/Kconfig          |  130 ++
 drivers/net/wireless/rt2x00/Makefile         |   22 +
 drivers/net/wireless/rt2x00/rt2400pci.c      | 1689 +++++++++++++++++
 drivers/net/wireless/rt2x00/rt2400pci.h      |  943 ++++++++++
 drivers/net/wireless/rt2x00/rt2500pci.c      | 2000 ++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2500pci.h      | 1236 ++++++++++++
 drivers/net/wireless/rt2x00/rt2500usb.c      | 1837 ++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2500usb.h      |  798 ++++++++
 drivers/net/wireless/rt2x00/rt2x00.h         |  807 ++++++++
 drivers/net/wireless/rt2x00/rt2x00config.c   |  165 ++
 drivers/net/wireless/rt2x00/rt2x00debug.c    |  331 ++++
 drivers/net/wireless/rt2x00/rt2x00debug.h    |   57 +
 drivers/net/wireless/rt2x00/rt2x00dev.c      | 1133 +++++++++++
 drivers/net/wireless/rt2x00/rt2x00firmware.c |  124 ++
 drivers/net/wireless/rt2x00/rt2x00lib.h      |  125 ++
 drivers/net/wireless/rt2x00/rt2x00mac.c      |  459 +++++
 drivers/net/wireless/rt2x00/rt2x00pci.c      |  481 +++++
 drivers/net/wireless/rt2x00/rt2x00pci.h      |  127 ++
 drivers/net/wireless/rt2x00/rt2x00reg.h      |  283 +++
 drivers/net/wireless/rt2x00/rt2x00rfkill.c   |  148 ++
 drivers/net/wireless/rt2x00/rt2x00ring.h     |  255 +++
 drivers/net/wireless/rt2x00/rt2x00usb.c      |  595 ++++++
 drivers/net/wireless/rt2x00/rt2x00usb.h      |  180 ++
 drivers/net/wireless/rt2x00/rt61pci.c        | 2603 ++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt61pci.h        | 1457 ++++++++++++++
 drivers/net/wireless/rt2x00/rt73usb.c        | 2124 +++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt73usb.h        | 1024 ++++++++++
 31 files changed, 21175 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/Kconfig
 create mode 100644 drivers/net/wireless/rt2x00/Makefile
 create mode 100644 drivers/net/wireless/rt2x00/rt2400pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2400pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2500pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2500pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2500usb.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2500usb.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00config.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00debug.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00debug.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00dev.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00firmware.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00lib.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mac.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00reg.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00rfkill.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00ring.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00usb.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00usb.h
 create mode 100644 drivers/net/wireless/rt2x00/rt61pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt61pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt73usb.c
 create mode 100644 drivers/net/wireless/rt2x00/rt73usb.h
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
