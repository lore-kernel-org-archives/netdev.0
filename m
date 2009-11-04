From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 00/12] WiMAX pull request
Date: Wed,  4 Nov 2009 13:40:05 -0800
Message-ID: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932781AbZKDVmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 4a78fd9a736db4c871bc8b583d66b61c38abd299:
  Inaky Perez-Gonzalez (1):
        wimax/i2400m: fix oops caused by race condition when exiting USB kthreads

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.33.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (12):
      wimax/i2400m: make i2400m->bus_dev_{stop,start}() optional
      wimax/i2400m: SDIO: fix oops on reset when TXing on uninitialized data
      wimax/i2400m: implement passive mode as a module option
      wimax/i2400m: introduce i2400m_reset(), stopping TX and carrier
      wimax/i2400m: fix device getting stuck in IDLE mode
      wimax/i2400m: Fix USB timeout specifications (to ms from HZ)
      wimax/i2400m: correctly identify all iwmc3200-based SKUs
      wimax/i2400m: don't retry SDIO enable in probe() paths
      wimax/i2400m: handle USB stalls
      wimax/i2400m: fix bad assignment of return value in i2400mu_tx_bulk_out
      wimax/i2400m: fix SDIO debugfs dentry name
      wimax/i2400m: fix inverted value in i2400ms_bus_setup()

 drivers/net/wimax/i2400m/control.c     |   14 +++++-
 drivers/net/wimax/i2400m/debugfs.c     |    2 +-
 drivers/net/wimax/i2400m/driver.c      |   36 +++++++++++---
 drivers/net/wimax/i2400m/fw.c          |    4 +-
 drivers/net/wimax/i2400m/i2400m-sdio.h |   11 ++++
 drivers/net/wimax/i2400m/i2400m.h      |   15 +++---
 drivers/net/wimax/i2400m/netdev.c      |   25 +++++++--
 drivers/net/wimax/i2400m/rx.c          |    4 +-
 drivers/net/wimax/i2400m/sdio.c        |   81 ++++++++++++++------------------
 drivers/net/wimax/i2400m/usb-fw.c      |   25 +++++++++-
 drivers/net/wimax/i2400m/usb-rx.c      |   23 +++++++++-
 drivers/net/wimax/i2400m/usb-tx.c      |   24 +++++++++-
 drivers/net/wimax/i2400m/usb.c         |   61 +++++++++++++++++++++---
 13 files changed, 240 insertions(+), 85 deletions(-)
