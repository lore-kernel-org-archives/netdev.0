From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
Date: Wed, 09 Nov 2016 10:19:57 -0500
Message-ID: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, konrad.wilk@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is a subset of the patches originally submitted with the
above patch title.  Specifically all of these patches relate to the
swiotlb.

I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
no updates are required for the previous set then this patch set can be
ignored since most of the changes are just cosmetic.

v1: Split out changes DMA_ERROR_CODE fix for swiotlb-xen
    Minor fixes based on issues found by kernel build bot
    Few minor changes for issues found on code review
    Added Acked-by for patches that were acked and not changed

v2: Added a few more Acked-by
    Added swiotlb_unmap_sg to functions dropped in patch 1, dropped Acked-by
    Submitting patches to mm instead of net-next

v3: Split patch set, first 3 to swiotlb, remaining 23 still to mm
    Minor clean-ups for swiotlb code, mostly cosmetic
    Replaced my patch with the one originally submitted by Christoph Hellwig

---

Alexander Duyck (2):
      swiotlb-xen: Enforce return of DMA_ERROR_CODE in mapping function
      swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC

Christoph Hellwig (1):
      swiotlb: remove unused swiotlb_map_sg and swiotlb_unmap_sg functions


 arch/arm/xen/mm.c              |    1 -
 arch/x86/xen/pci-swiotlb-xen.c |    1 -
 drivers/xen/swiotlb-xen.c      |   19 +++++---------
 include/linux/swiotlb.h        |   14 +++--------
 include/xen/swiotlb-xen.h      |    3 --
 lib/swiotlb.c                  |   53 +++++++++++++++++-----------------------
 6 files changed, 33 insertions(+), 58 deletions(-)

--
