From: Gregory Haskins <ghaskins@novell.com>
Subject: [PATCH 0/7] AlacrityVM guest drivers
Date: Mon, 03 Aug 2009 13:17:30 -0400
Message-ID: <20090803171030.17268.26962.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751971AbZHCRRn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Applies to v2.6.31-rc5, proposed for linux-next after review is complete)

This series implements the guest-side drivers for accelerated IO
when running on top of the AlacrityVM hypervisor, the details of
which you can find here:

http://developer.novell.com/wiki/index.php/AlacrityVM

This series includes the basic plumbing, as well as the driver for
accelerated 802.x (ethernet) networking.

Regards,
-Greg

---

Gregory Haskins (7):
      venet: add scatter-gather/GSO support
      net: Add vbus_enet driver
      ioq: add driver-side vbus helpers
      vbus-proxy: add a pci-to-vbus bridge
      vbus: add a "vbus-proxy" bus model for vbus_driver objects
      ioq: Add basic definitions for a shared-memory, lockless queue
      shm-signal: shared-memory signals


 arch/x86/Kconfig            |    2 
 drivers/Makefile            |    1 
 drivers/net/Kconfig         |   14 +
 drivers/net/Makefile        |    1 
 drivers/net/vbus-enet.c     |  899 +++++++++++++++++++++++++++++++++++++++++++
 drivers/vbus/Kconfig        |   24 +
 drivers/vbus/Makefile       |    6 
 drivers/vbus/bus-proxy.c    |  216 ++++++++++
 drivers/vbus/pci-bridge.c   |  824 +++++++++++++++++++++++++++++++++++++++
 include/linux/Kbuild        |    4 
 include/linux/ioq.h         |  415 ++++++++++++++++++++
 include/linux/shm_signal.h  |  189 +++++++++
 include/linux/vbus_driver.h |   80 ++++
 include/linux/vbus_pci.h    |  127 ++++++
 include/linux/venet.h       |   84 ++++
 lib/Kconfig                 |   21 +
 lib/Makefile                |    2 
 lib/ioq.c                   |  294 ++++++++++++++
 lib/shm_signal.c            |  192 +++++++++
 19 files changed, 3395 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/vbus-enet.c
 create mode 100644 drivers/vbus/Kconfig
 create mode 100644 drivers/vbus/Makefile
 create mode 100644 drivers/vbus/bus-proxy.c
 create mode 100644 drivers/vbus/pci-bridge.c
 create mode 100644 include/linux/ioq.h
 create mode 100644 include/linux/shm_signal.h
 create mode 100644 include/linux/vbus_driver.h
 create mode 100644 include/linux/vbus_pci.h
 create mode 100644 include/linux/venet.h
 create mode 100644 lib/ioq.c
 create mode 100644 lib/shm_signal.c

-- 
Signature
