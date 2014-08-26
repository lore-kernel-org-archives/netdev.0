From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/4] stmmac: fix the EEE LPI Macro definitions.
Date: Tue, 26 Aug 2014 09:16:20 +0200
Message-ID: <1409037383-3213-2-git-send-email-peppe.cavallaro@st.com>
References: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nandini sharma <nandini.sharma@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:57974 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535AbaHZHQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:16:31 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q7AAed024447
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:30 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hn092sw-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:30 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 56A4E34
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:20 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A2630164E5
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:28 +0000 (GMT)
In-Reply-To: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nandini sharma <nandini.sharma@st.com>

This patch is to fix the definition of macros for EEE otherwise the LPI TX/RX
entry/exit cannot be properly managed.

Signed-off-by: Nandini Sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index de507c3..a464e8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -220,10 +220,10 @@ enum dma_irq_status {
 	handle_tx = 0x8,
 };
 
-#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 1)
-#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 2)
-#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 3)
-#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 4)
+#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 0)
+#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 1)
+#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 2)
+#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 3)
 
 #define	CORE_PCS_ANE_COMPLETE		(1 << 5)
 #define	CORE_PCS_LINK_STATUS		(1 << 6)
-- 
1.7.4.4
