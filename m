From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/4] stmmac: fix LPI TW timer value to 20.5us.
Date: Tue, 26 Aug 2014 09:16:21 +0200
Message-ID: <1409037383-3213-3-git-send-email-peppe.cavallaro@st.com>
References: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nandini sharma <nandini.sharma@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47435 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535AbaHZHQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:16:35 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q79iZG026737
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:33 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hrgs1yh-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:33 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A4ABE38
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:23 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 09772164E5
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:32 +0000 (GMT)
In-Reply-To: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nandini sharma <nandini.sharma@st.com>

The value for LPI TW timer has to be updated to 0x1E that is the hardcoded value
of 20.5us and it will apply to all EEE enabled Remote PHYs.
Disadvantage is for PHY's that support lesser wakeup time but we can accept it
waiting to implement LLDP to negotiate the Wakeup time of Remote PHY.

Signed-off-by: nandini sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index a464e8c..9f3e8b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -287,7 +287,7 @@ struct dma_features {
 
 /* Default LPI timers */
 #define STMMAC_DEFAULT_LIT_LS	0x3E8
-#define STMMAC_DEFAULT_TWT_LS	0x0
+#define STMMAC_DEFAULT_TWT_LS	0x1E
 
 #define STMMAC_CHAIN_MODE	0x1
 #define STMMAC_RING_MODE	0x2
-- 
1.7.4.4
