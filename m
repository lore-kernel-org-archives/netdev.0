From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'b43' branch of wireless-2.6
Date: Tue, 18 Sep 2007 16:28:19 -0400
Message-ID: <20070918202819.GI4940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff & Dave,

This series adds the b43 and b43legacy drivers, as well as the ssb
bus infrastructure upon which they depend.

These drivers support the BCM43xx wireless hardware from Broadcom.
The b43 driver supports modern hardware using the "version 4" firmware,
while the b43legacy driver uses the "version 3" firmware to support
some older devices which lack the resources to run the newer (and
more feature rich) firmware.  Both drivers have performed well in
-mm and Fedora rawhide, and b43 has performed well in later Fedora
7 kernels as well.

Furthermore, Michael and Larry have both demonstrated a strong
commitment to the community and their users.  They both have responded
to bugs both at the kernel.org bugzilla and in distro bugzillas.
I have every confidence that they will continue to support their
drivers at the same high standard that have already set.  I'd like
to take this opportunity to thank both of them for their support both
in the past and in the future as well.

No doubt there are still problems here.  But again, I think we would
be better served by mainlining this code rather than continuing to
maintain it out of stream.

Thanks!

John

---

Patches are here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/b43/

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git b43

Larry Finger (1):
      b43legacy: add mac80211-based driver for legacy BCM43xx devices

Michael Buesch (2):
      ssb: add Sonics Silicon Backplane bus support
      b43: add mac80211-based driver for modern BCM43xx devices

 MAINTAINERS                                |   22 +
 drivers/Kconfig                            |    2 +
 drivers/Makefile                           |    1 +
 drivers/net/wireless/Kconfig               |    2 +
 drivers/net/wireless/Makefile              |    2 +
 drivers/net/wireless/b43/Kconfig           |  119 +
 drivers/net/wireless/b43/Makefile          |   17 +
 drivers/net/wireless/b43/b43.h             |  845 ++++++
 drivers/net/wireless/b43/debugfs.c         |  654 +++++
 drivers/net/wireless/b43/debugfs.h         |   89 +
 drivers/net/wireless/b43/dma.c             | 1494 ++++++++++
 drivers/net/wireless/b43/dma.h             |  337 +++
 drivers/net/wireless/b43/leds.c            |  299 ++
 drivers/net/wireless/b43/leds.h            |   55 +
 drivers/net/wireless/b43/lo.c              | 1261 ++++++++
 drivers/net/wireless/b43/lo.h              |  112 +
 drivers/net/wireless/b43/main.c            | 4091 ++++++++++++++++++++++++++
 drivers/net/wireless/b43/main.h            |  142 +
 drivers/net/wireless/b43/pcmcia.c          |  157 +
 drivers/net/wireless/b43/pcmcia.h          |   20 +
 drivers/net/wireless/b43/phy.c             | 4351 ++++++++++++++++++++++++++++
 drivers/net/wireless/b43/phy.h             |  297 ++
 drivers/net/wireless/b43/pio.c             |  650 +++++
 drivers/net/wireless/b43/pio.h             |  153 +
 drivers/net/wireless/b43/sysfs.c           |  235 ++
 drivers/net/wireless/b43/sysfs.h           |    9 +
 drivers/net/wireless/b43/tables.c          |  375 +++
 drivers/net/wireless/b43/tables.h          |   28 +
 drivers/net/wireless/b43/xmit.c            |  648 +++++
 drivers/net/wireless/b43/xmit.h            |  250 ++
 drivers/net/wireless/b43legacy/Kconfig     |   89 +
 drivers/net/wireless/b43legacy/Makefile    |   14 +
 drivers/net/wireless/b43legacy/b43legacy.h |  829 ++++++
 drivers/net/wireless/b43legacy/debugfs.c   |  505 ++++
 drivers/net/wireless/b43legacy/debugfs.h   |   89 +
 drivers/net/wireless/b43legacy/dma.c       | 1565 ++++++++++
 drivers/net/wireless/b43legacy/dma.h       |  367 +++
 drivers/net/wireless/b43legacy/ilt.c       |  336 +++
 drivers/net/wireless/b43legacy/ilt.h       |   34 +
 drivers/net/wireless/b43legacy/leds.c      |  302 ++
 drivers/net/wireless/b43legacy/leds.h      |   56 +
 drivers/net/wireless/b43legacy/main.c      | 3805 ++++++++++++++++++++++++
 drivers/net/wireless/b43legacy/main.h      |  147 +
 drivers/net/wireless/b43legacy/phy.c       | 2265 +++++++++++++++
 drivers/net/wireless/b43legacy/phy.h       |  219 ++
 drivers/net/wireless/b43legacy/pio.c       |  668 +++++
 drivers/net/wireless/b43legacy/pio.h       |  172 ++
 drivers/net/wireless/b43legacy/radio.c     | 2131 ++++++++++++++
 drivers/net/wireless/b43legacy/radio.h     |   98 +
 drivers/net/wireless/b43legacy/sysfs.c     |  238 ++
 drivers/net/wireless/b43legacy/sysfs.h     |    9 +
 drivers/net/wireless/b43legacy/xmit.c      |  642 ++++
 drivers/net/wireless/b43legacy/xmit.h      |  259 ++
 drivers/ssb/Kconfig                        |  117 +
 drivers/ssb/Makefile                       |   18 +
 drivers/ssb/b43_pci_bridge.c               |   46 +
 drivers/ssb/driver_chipcommon.c            |  446 +++
 drivers/ssb/driver_extif.c                 |  129 +
 drivers/ssb/driver_mipscore.c              |  223 ++
 drivers/ssb/driver_pcicore.c               |  576 ++++
 drivers/ssb/main.c                         | 1162 ++++++++
 drivers/ssb/pci.c                          |  740 +++++
 drivers/ssb/pcihost_wrapper.c              |  104 +
 drivers/ssb/pcmcia.c                       |  271 ++
 drivers/ssb/scan.c                         |  413 +++
 drivers/ssb/ssb_private.h                  |  136 +
 include/linux/mod_devicetable.h            |   15 +
 include/linux/ssb/ssb.h                    |  424 +++
 include/linux/ssb/ssb_driver_chipcommon.h  |  396 +++
 include/linux/ssb/ssb_driver_extif.h       |  204 ++
 include/linux/ssb/ssb_driver_mips.h        |   46 +
 include/linux/ssb/ssb_driver_pci.h         |  106 +
 include/linux/ssb/ssb_regs.h               |  292 ++
 scripts/mod/file2alias.c                   |   19 +
 74 files changed, 37439 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wireless/b43/Kconfig
 create mode 100644 drivers/net/wireless/b43/Makefile
 create mode 100644 drivers/net/wireless/b43/b43.h
 create mode 100644 drivers/net/wireless/b43/debugfs.c
 create mode 100644 drivers/net/wireless/b43/debugfs.h
 create mode 100644 drivers/net/wireless/b43/dma.c
 create mode 100644 drivers/net/wireless/b43/dma.h
 create mode 100644 drivers/net/wireless/b43/leds.c
 create mode 100644 drivers/net/wireless/b43/leds.h
 create mode 100644 drivers/net/wireless/b43/lo.c
 create mode 100644 drivers/net/wireless/b43/lo.h
 create mode 100644 drivers/net/wireless/b43/main.c
 create mode 100644 drivers/net/wireless/b43/main.h
 create mode 100644 drivers/net/wireless/b43/pcmcia.c
 create mode 100644 drivers/net/wireless/b43/pcmcia.h
 create mode 100644 drivers/net/wireless/b43/phy.c
 create mode 100644 drivers/net/wireless/b43/phy.h
 create mode 100644 drivers/net/wireless/b43/pio.c
 create mode 100644 drivers/net/wireless/b43/pio.h
 create mode 100644 drivers/net/wireless/b43/sysfs.c
 create mode 100644 drivers/net/wireless/b43/sysfs.h
 create mode 100644 drivers/net/wireless/b43/tables.c
 create mode 100644 drivers/net/wireless/b43/tables.h
 create mode 100644 drivers/net/wireless/b43/xmit.c
 create mode 100644 drivers/net/wireless/b43/xmit.h
 create mode 100644 drivers/net/wireless/b43legacy/Kconfig
 create mode 100644 drivers/net/wireless/b43legacy/Makefile
 create mode 100644 drivers/net/wireless/b43legacy/b43legacy.h
 create mode 100644 drivers/net/wireless/b43legacy/debugfs.c
 create mode 100644 drivers/net/wireless/b43legacy/debugfs.h
 create mode 100644 drivers/net/wireless/b43legacy/dma.c
 create mode 100644 drivers/net/wireless/b43legacy/dma.h
 create mode 100644 drivers/net/wireless/b43legacy/ilt.c
 create mode 100644 drivers/net/wireless/b43legacy/ilt.h
 create mode 100644 drivers/net/wireless/b43legacy/leds.c
 create mode 100644 drivers/net/wireless/b43legacy/leds.h
 create mode 100644 drivers/net/wireless/b43legacy/main.c
 create mode 100644 drivers/net/wireless/b43legacy/main.h
 create mode 100644 drivers/net/wireless/b43legacy/phy.c
 create mode 100644 drivers/net/wireless/b43legacy/phy.h
 create mode 100644 drivers/net/wireless/b43legacy/pio.c
 create mode 100644 drivers/net/wireless/b43legacy/pio.h
 create mode 100644 drivers/net/wireless/b43legacy/radio.c
 create mode 100644 drivers/net/wireless/b43legacy/radio.h
 create mode 100644 drivers/net/wireless/b43legacy/sysfs.c
 create mode 100644 drivers/net/wireless/b43legacy/sysfs.h
 create mode 100644 drivers/net/wireless/b43legacy/xmit.c
 create mode 100644 drivers/net/wireless/b43legacy/xmit.h
 create mode 100644 drivers/ssb/Kconfig
 create mode 100644 drivers/ssb/Makefile
 create mode 100644 drivers/ssb/b43_pci_bridge.c
 create mode 100644 drivers/ssb/driver_chipcommon.c
 create mode 100644 drivers/ssb/driver_extif.c
 create mode 100644 drivers/ssb/driver_mipscore.c
 create mode 100644 drivers/ssb/driver_pcicore.c
 create mode 100644 drivers/ssb/main.c
 create mode 100644 drivers/ssb/pci.c
 create mode 100644 drivers/ssb/pcihost_wrapper.c
 create mode 100644 drivers/ssb/pcmcia.c
 create mode 100644 drivers/ssb/scan.c
 create mode 100644 drivers/ssb/ssb_private.h
 create mode 100644 include/linux/ssb/ssb.h
 create mode 100644 include/linux/ssb/ssb_driver_chipcommon.h
 create mode 100644 include/linux/ssb/ssb_driver_extif.h
 create mode 100644 include/linux/ssb/ssb_driver_mips.h
 create mode 100644 include/linux/ssb/ssb_driver_pci.h
 create mode 100644 include/linux/ssb/ssb_regs.h
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
