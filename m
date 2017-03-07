From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 0/4] net: thunderx: Miscellaneous fixes
Date: Tue,  7 Mar 2017 18:09:07 +0530
Message-ID: <1488890351-18493-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch set fixes multiple issues such as IOMMU
translation faults when kernel is booted with IOMMU enabled
on host, incorrect MAC ID reading from ACPI tables and IPv6
UDP packet drop due to failure of checksum validation.

Changes from v1:
- As suggested by David Miller, got rid of conditional
  calling of DMA map/unmap APIs. Also updated commit message
  in 'IOMMU translation faults' patch.

Sunil Goutham (3):
  net: thunderx: Fix IOMMU translation faults
  net: thunderx: Fix LMAC mode debug prints for QSGMII mode
  net: thunderx: Fix invalid mac addresses for node1 interfaces

Thanneeru Srinivasulu (1):
  net: thunderx: Allow IPv6 frames with zero UDP checksum

 drivers/net/ethernet/cavium/thunder/nic.h          |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  12 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 184 ++++++++++++++++-----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   4 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  64 ++++---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |   1 -
 6 files changed, 205 insertions(+), 61 deletions(-)

-- 
2.7.4
