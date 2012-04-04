From: Dave Jiang <dave.jiang@intel.com>
Subject: [PATCH 0/3] Series short description
Date: Wed, 04 Apr 2012 16:10:30 -0700
Message-ID: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: dan.j.williams@intel.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series address issues with the ioatdma driver. The first
patch fixes a potential ring size overflow. The next two patches put
in alignment requirement for silicon errata on the ioatdma hardware related to
M2M ops and impacts NETDMA. The last patch will probably need to be
ack'd by David Miller as it touches the network subsystem.
---

Dave Jiang (3):
      netdma: adding alignment check for NETDMA ops
      ioatdma: DMA copy alignment needed to address IOAT DMA silicon errata
      ioat: ring size variables need to be 32bit to avoid overflow


 drivers/dma/dmaengine.c   |   14 ++++++++++++++
 drivers/dma/ioat/dma_v2.c |    4 ++--
 drivers/dma/ioat/dma_v2.h |    4 ++--
 drivers/dma/ioat/dma_v3.c |   41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/dmaengine.h |    1 +
 net/ipv4/tcp.c            |    4 ++--
 net/ipv4/tcp_input.c      |    2 +-
 net/ipv4/tcp_ipv4.c       |    2 +-
 net/ipv6/tcp_ipv6.c       |    2 +-
 9 files changed, 65 insertions(+), 9 deletions(-)

-- 
