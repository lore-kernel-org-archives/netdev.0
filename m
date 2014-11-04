From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 03/12] amd-xgbe: Use the u32 data type for
 descriptors
Date: Tue, 4 Nov 2014 16:06:37 -0600
Message-ID: <20141104220637.24738.94490.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0108.outbound.protection.outlook.com ([157.56.110.108]:6066
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752484AbaKDWGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:44 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tx and Rx descriptors are unsigned 32 bit values.  Use the u32
type, rather than unsigned int, to map these descriptors.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 0dc15d7..19f1d90 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -234,10 +234,10 @@ struct xgbe_packet_data {
 
 /* Common Rx and Tx descriptor mapping */
 struct xgbe_ring_desc {
-	unsigned int desc0;
-	unsigned int desc1;
-	unsigned int desc2;
-	unsigned int desc3;
+	u32 desc0;
+	u32 desc1;
+	u32 desc2;
+	u32 desc3;
 };
 
 /* Structure used to hold information related to the descriptor
