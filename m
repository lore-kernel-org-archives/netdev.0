From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 11/14] ehea: Remove some unused definitions
Date: Tue, 5 Apr 2011 21:41:45 +1000
Message-ID: <20110405214145.4d2dc8f6@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37409 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1DELls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:41:48 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The queue macros are many levels deep and it makes it harder to
work your way through them when many of the versions are unused.
Remove the unused versions.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_hw.h
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_hw.h	2011-03-21 14:18:18.642367504 +1100
+++ linux-2.6/drivers/net/ehea/ehea_hw.h	2011-03-21 14:18:52.523619465 +1100
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
