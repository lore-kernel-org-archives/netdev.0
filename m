From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/4] netxen: fix unified fw size check
Date: Tue,  8 Dec 2009 22:40:57 -0800
Message-ID: <1260340857-11487-5-git-send-email-amit.salecha@qlogic.com>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53141 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755771AbZLIGkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 01:40:51 -0500
In-Reply-To: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Unified firmware image size can be < 1 MB

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 76cd1f3..c1223c9 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -420,7 +420,7 @@ struct status_desc {
 } __attribute__ ((aligned(16)));
 
 /* UNIFIED ROMIMAGE *************************/
-#define NX_UNI_FW_MIN_SIZE		0x3eb000
+#define NX_UNI_FW_MIN_SIZE		0xc8000
 #define NX_UNI_DIR_SECT_PRODUCT_TBL	0x0
 #define NX_UNI_DIR_SECT_BOOTLD		0x6
 #define NX_UNI_DIR_SECT_FW		0x7
-- 
1.6.0.2

