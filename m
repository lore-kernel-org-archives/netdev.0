From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 05/12] bnx2x: Add missing VFs reference in
 macros
Date: Wed, 23 Jan 2013 15:21:47 +0200
Message-ID: <1358947314-3851-6-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1312 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890Ab3AWOXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:18 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing 57712_VF and 57800_VF to CHIP_IS_E2 and CHIP_IS_E3
macros (missing from commit 8395be5).

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 9e8c37d..0532e43 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -843,9 +843,11 @@ struct bnx2x_common {
 #define CHIP_IS_E1H(bp)			(CHIP_IS_57711(bp) || \
 					 CHIP_IS_57711E(bp))
 #define CHIP_IS_E2(bp)			(CHIP_IS_57712(bp) || \
-					 CHIP_IS_57712_MF(bp))
+					 CHIP_IS_57712_MF(bp) || \
+					 CHIP_IS_57712_VF(bp))
 #define CHIP_IS_E3(bp)			(CHIP_IS_57800(bp) || \
 					 CHIP_IS_57800_MF(bp) || \
+					 CHIP_IS_57800_VF(bp) || \
 					 CHIP_IS_57810(bp) || \
 					 CHIP_IS_57810_MF(bp) || \
 					 CHIP_IS_57810_VF(bp) || \
-- 
1.8.1.227.g44fe835
