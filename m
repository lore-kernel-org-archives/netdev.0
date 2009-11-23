From: Gregory Haskins <ghaskins@novell.com>
Subject: [-next PATCH 0/4] Minor fixes for alacrityvm/linux-next branch
Date: Mon, 23 Nov 2009 14:54:28 -0500
Message-ID: <20091123195136.8184.68042.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: linux-next@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following are trivial fixes for the drivers in alacrityvm/linux-next

Patches 1-3 were necessary to enable the building of these drivers
as a KMP package for older distribution kernels. Patch 4/4 is just
a cleanup discovered during testing.

Kind Regards,
-Greg

---

Gregory Haskins (4):
      vbus: fix pcibridge busmaster support
      vbus: add autoprobe capability to guest
      venet: add missing ethtool include
      vbus: make library code properly declared as GPL


 drivers/net/vbus-enet.c     |    3 +++
 drivers/vbus/bus-proxy.c    |   33 ++++++++++++++++++++++++++++++++-
 drivers/vbus/pci-bridge.c   |    2 ++
 include/linux/vbus_driver.h |    2 ++
 lib/ioq.c                   |    4 ++++
 lib/shm_signal.c            |    4 ++++
 6 files changed, 47 insertions(+), 1 deletions(-)

-- 
Signature
