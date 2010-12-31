From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 3/7] net/atl1c/atl1c.h Typo change desciptor to descriptor.
Date: Fri, 31 Dec 2010 09:39:03 -0800
Message-ID: <1293817143-8013-1-git-send-email-justinmattock@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Below is a patch, that changes a typo from "desciptor" to "descriptor".
Let me know if I missed anything.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/net/atl1c/atl1c.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 9ab5809..7cb375e 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -265,7 +265,7 @@ struct atl1c_recv_ret_status {
 	__le32	word3;
 };
 
-/* RFD desciptor */
+/* RFD descriptor */
 struct atl1c_rx_free_desc {
 	__le64	buffer_addr;
 };
@@ -531,7 +531,7 @@ struct atl1c_rfd_ring {
 	struct atl1c_buffer *buffer_info;
 };
 
-/* receive return desciptor (rrd) ring */
+/* receive return descriptor (rrd) ring */
 struct atl1c_rrd_ring {
 	void *desc;		/* descriptor ring virtual address */
 	dma_addr_t dma;		/* descriptor ring physical address */
-- 
1.6.5.2.180.gc5b3e
