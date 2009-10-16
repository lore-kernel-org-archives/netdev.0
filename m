From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/7] netxen: defines for next revision
Date: Thu, 15 Oct 2009 23:09:08 -0700
Message-ID: <1255673353-31797-3-git-send-email-dhananjay@netxen.com>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>,
	Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45933 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753709AbZJPGJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 02:09:50 -0400
In-Reply-To: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 3d990e5..b1aca52 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -117,9 +117,11 @@
 #define NX_P3_B0		0x40
 #define NX_P3_B1		0x41
 #define NX_P3_B2		0x42
+#define NX_P3P_A0		0x50
 
 #define NX_IS_REVISION_P2(REVISION)     (REVISION <= NX_P2_C1)
 #define NX_IS_REVISION_P3(REVISION)     (REVISION >= NX_P3_A0)
+#define NX_IS_REVISION_P3P(REVISION)     (REVISION >= NX_P3P_A0)
 
 #define FIRST_PAGE_GROUP_START	0
 #define FIRST_PAGE_GROUP_END	0x100000
-- 
1.6.0.2

