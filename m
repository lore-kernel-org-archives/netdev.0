From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: Fix sparse endian warnings
Date: Wed, 12 Nov 2014 10:37:49 -0600
Message-ID: <20141112163749.2808.95593.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0128.outbound.protection.outlook.com ([207.46.100.128]:27616
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752898AbaKLQhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 11:37:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the types of the descriptor entries in the xgbe_ring_desc struct
from u32 to __le32 to fix endian warnings issued by sparse.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index aa8da9f..901fb1f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -246,10 +246,10 @@ struct xgbe_packet_data {
 
 /* Common Rx and Tx descriptor mapping */
 struct xgbe_ring_desc {
-	u32 desc0;
-	u32 desc1;
-	u32 desc2;
-	u32 desc3;
+	__le32 desc0;
+	__le32 desc1;
+	__le32 desc2;
+	__le32 desc3;
 };
 
 /* Page allocation related values */
