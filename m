From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH v2 0/4] I/OAT: watchdog/reset,
	tcp_dma_copybreak and I/OAT ver.3 support
Date: Fri, 18 Jul 2008 17:27:08 +0200
Message-ID: <20080718152541.21235.85961.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbYGRPg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 11:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 2 of ioatdma patchset
which has been updated after first review comments.
The first three patches are a result of 
ioatdma sustaining and performance tuning efforts
for both I/OAT versions 1.2 and 2.0.
The fourth patch is a new patch in this set. 
It adds I/OAT version 3 support to ioatdma driver.

The main differences between v1 and v2 of this patchset are:
 * "Increase sleep time in ioat_dma_self_test" change 
   has been separated from 
   "Add watchdog/reset functionality to ioatdma driver" patch
 * tcp_dma_copybreak default value setting has been moved
   from dmaengine to ioatdma driver
 * "I/OAT version 3.0 support" patch has been added
 * checkpatch problems have been resolved

This patches apply to kernel 2.6.26-rc9.

Maciej Sosnowski (4):
     I/OAT: Add watchdog/reset functionality to ioatdma driver
     I/OAT: Increase sleep time in ioat_dma_self_test
     I/OAT: tcp_dma_copybreak default value dependant on I/OAT version
     I/OAT: I/OAT version 3.0 support

 drivers/dca/dca-core.c          |  131 +++++++--
 drivers/dca/dca-sysfs.c         |    3 
 drivers/dma/ioat.c              |   15 +
 drivers/dma/ioat_dca.c          |  244 ++++++++++++++++++
 drivers/dma/ioat_dma.c          |  395 ++++++++++++++++++++++++++++--
 drivers/dma/ioatdma.h           |   14 -
 drivers/dma/ioatdma_hw.h        |    1 
 drivers/dma/ioatdma_registers.h |   20 +
 include/linux/dca.h             |    7 
 include/linux/pci_ids.h         |    8 
 net/core/user_dma.c             |    1 
 11 files changed, 783 insertions(+), 56 deletions(-)

--
Maciej
