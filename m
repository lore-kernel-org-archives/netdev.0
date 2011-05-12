From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 11/15] ehea: Remove some unused definitions
Date: Thu, 12 May 2011 10:52:24 +1000
Message-ID: <20110512005623.471148742@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53663 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775Ab1ELBm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:42:58 -0400
Content-Disposition: inline; filename=ehea_15.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The queue macros are many levels deep and it makes it harder to
work your way through them when many of the versions are unused.
Remove the unused versions.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_hw.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_hw.h	2011-05-12 07:47:05.769421104 +1000
+++ linux-net/drivers/net/ehea/ehea_hw.h	2011-05-12 07:48:01.630306772 +1000
@@ -210,36 +210,11 @@ static inline void epa_store_acc(struct
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


