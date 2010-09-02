From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb3: Add register bit definition for Fatal Parity Error.
Date: Thu,  2 Sep 2010 16:07:29 -0700
Message-ID: <1283468852-1010-1-git-send-email-leedom@chelsio.com>
References: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21240 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab0IBXHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:07:36 -0400
In-Reply-To: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb3/regs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index cb42353..6990f6c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1997,6 +1997,10 @@
 
 #define A_PL_RST 0x6f0
 
+#define S_FATALPERREN    4
+#define V_FATALPERREN(x) ((x) << S_FATALPERREN)
+#define F_FATALPERREN    V_FATALPERREN(1U)
+
 #define S_CRSTWRM    1
 #define V_CRSTWRM(x) ((x) << S_CRSTWRM)
 #define F_CRSTWRM    V_CRSTWRM(1U)
-- 
1.7.0.4

