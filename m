From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 11/15] ehea: Remove some unused definitions
Date: Fri, 14 Oct 2011 12:31:08 -0300
Message-ID: <1318606272-27647-12-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51443 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933222Ab1JNPbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:49 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqcCe010468
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:38 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZMlk3285060
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:22 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVbCd008793
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:37 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

The queue macros are many levels deep and it makes it harder to
work your way through them when many of the versions are unused.
Remove the unused versions.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_hw.h |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_hw.h b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
index 567981b..1a2fe4d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_hw.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
@@ -210,36 +210,11 @@ static inline void epa_store_acc(struct h_epa epa, u32 offset, u64 value)
 	__raw_writeq(value, (void __iomem *)(epa.addr + offset));
 }
 
-#define epa_store_eq(epa, offset, value)\
-	epa_store(epa, EQTEMM_OFFSET(offset), value)
-#define epa_load_eq(epa, offset)\
-	epa_load(epa, EQTEMM_OFFSET(offset))
-
 #define epa_store_cq(epa, offset, value)\
 	epa_store(epa, CQTEMM_OFFSET(offset), value)
 #define epa_load_cq(epa, offset)\
 	epa_load(epa, CQTEMM_OFFSET(offset))
 
-#define epa_store_qp(epa, offset, value)\
-	epa_store(epa, QPTEMM_OFFSET(offset), value)
-#define epa_load_qp(epa, offset)\
-	epa_load(epa, QPTEMM_OFFSET(offset))
-
-#define epa_store_qped(epa, offset, value)\
-	epa_store(epa, QPEDMM_OFFSET(offset), value)
-#define epa_load_qped(epa, offset)\
-	epa_load(epa, QPEDMM_OFFSET(offset))
-
-#define epa_store_mrmw(epa, offset, value)\
-	epa_store(epa, MRMWMM_OFFSET(offset), value)
-#define epa_load_mrmw(epa, offset)\
-	epa_load(epa, MRMWMM_OFFSET(offset))
-
-#define epa_store_base(epa, offset, value)\
-	epa_store(epa, HCAGR_OFFSET(offset), value)
-#define epa_load_base(epa, offset)\
-	epa_load(epa, HCAGR_OFFSET(offset))
-
 static inline void ehea_update_sqa(struct ehea_qp *qp, u16 nr_wqes)
 {
 	struct h_epa epa = qp->epas.kernel;
-- 
1.7.4.4
