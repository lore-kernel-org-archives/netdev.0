From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 0/2] ioatdma: ring buffer management updates
Date: Tue, 11 May 2010 11:51:30 -0700
Message-ID: <20100511184949.6139.96826.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two patches targeted at the next merge window affecting the ioatdma
driver (used when NET_DMA and/or ASYNC_TX_DMA+MD_RAID456 are enabled).
According to perf the split locking update improves cpu utilization by a
few percentage points.

---

Dan Williams (2):
      ioat2,3: convert to producer/consumer locking
      ioat: convert to circ_buf


 drivers/dma/ioat/dma.h    |    1 
 drivers/dma/ioat/dma_v2.c |  184 +++++++++++++++++++++++----------------------
 drivers/dma/ioat/dma_v2.h |   33 +++-----
 drivers/dma/ioat/dma_v3.c |  117 +++++++++--------------------
 4 files changed, 142 insertions(+), 193 deletions(-)
