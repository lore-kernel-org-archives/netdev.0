From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/3] qlcnic: fix ocm window register offset calculation
Date: Fri, 17 Dec 2010 00:59:01 -0800
Message-ID: <1292576342-1359-3-git-send-email-amit.salecha@qlogic.com>
References: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:30440 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752114Ab0LQI72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 03:59:28 -0500
In-Reply-To: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

OCM window register offset was calculated incorrectly for
pci function greater than zero.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hdr.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 19328e0..726ef55 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -621,7 +621,7 @@ enum {
 #define PCIX_INT_MASK		(0x10104)
 
 #define PCIX_OCM_WINDOW		(0x10800)
-#define PCIX_OCM_WINDOW_REG(func)	(PCIX_OCM_WINDOW + 0x20 * (func))
+#define PCIX_OCM_WINDOW_REG(func)	(PCIX_OCM_WINDOW + 0x4 * (func))
 
 #define PCIX_TARGET_STATUS	(0x10118)
 #define PCIX_TARGET_STATUS_F1	(0x10160)
-- 
1.7.3.2

