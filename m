From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH 0/2] net: Fix compiler warnings
Date: Fri, 14 Oct 2016 17:06:04 -0700
Message-ID: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: chris.hyser@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recently, ATU (iommu) changes are submitted to linux-sparc that
enables 64bit DMA on SPARC. However, this change also makes
'incompatible pointer type' compiler warnings inevitable on sunqe
and sunbmac driver.

The two patches in series fix compiler warnings.

Tushar Dave (2):
  sunqe: Fix compiler warnings
  sunbmac: Fix compiler warning

 drivers/net/ethernet/sun/sunbmac.c |  5 +++--
 drivers/net/ethernet/sun/sunbmac.h |  2 +-
 drivers/net/ethernet/sun/sunqe.c   | 11 ++++++-----
 drivers/net/ethernet/sun/sunqe.h   |  4 ++--
 4 files changed, 12 insertions(+), 10 deletions(-)

-- 
1.9.1
