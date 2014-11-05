From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V1 3/4] can: add can_is_canfd_skb() API
Date: Wed, 5 Nov 2014 15:58:45 +0800
Message-ID: <1415174326-6623-3-git-send-email-b29396@freescale.com>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0135.outbound.protection.outlook.com ([157.56.111.135]:62982
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753440AbaKEJF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 04:05:26 -0500
In-Reply-To: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CAN device drivers can use it to check if the frame to send is on
CAN FD mode or normal CAN mode.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 include/linux/can/dev.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 6992afc..fe3be29 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -99,6 +99,11 @@ inval_skb:
 	return 1;
 }
 
+static inline int can_is_canfd_skb(struct sk_buff *skb)
+{
+	return skb->protocol == htons(ETH_P_CANFD);
+}
+
 /* get data length from can_dlc with sanitized can_dlc */
 u8 can_dlc2len(u8 can_dlc);
 
-- 
1.9.1
