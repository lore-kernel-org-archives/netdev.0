From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 55/86] chelsio/cxgb: use uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 15:41:36 +0200
Message-ID: <1427635734-24786-56-git-send-email-mst@redhat.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427635734-24786-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
use the new header directly so we can drop
the wrapper in include/linux/pci_ids.h.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb/common.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
index 53b1f94..e7af599 100644
--- a/drivers/net/ethernet/chelsio/cxgb/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb/common.h
@@ -51,7 +51,7 @@
 #include <linux/crc32.h>
 #include <linux/slab.h>
 #include <asm/io.h>
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 
 #define DRV_DESCRIPTION "Chelsio 10Gb Ethernet Driver"
 #define DRV_NAME "cxgb"
-- 
MST
