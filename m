From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 1/2] qlcnic: fix bandwidth check
Date: Sat, 24 Jul 2010 00:24:25 -0700
Message-ID: <1279956266-23445-2-git-send-email-amit.salecha@qlogic.com>
References: <1279956266-23445-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50853 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752508Ab0GXHY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jul 2010 03:24:28 -0400
In-Reply-To: <1279956266-23445-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Fix maximum and minmum bandwith value.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index e189477..fad8e9a 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1074,8 +1074,8 @@ struct qlcnic_eswitch {
 /* Return codes for Error handling */
 #define QL_STATUS_INVALID_PARAM	-1
 
-#define MAX_BW			10000
-#define MIN_BW			100
+#define MAX_BW			100
+#define MIN_BW			1
 #define MAX_VLAN_ID		4095
 #define MIN_VLAN_ID		2
 #define MAX_TX_QUEUES		1
@@ -1083,8 +1083,7 @@ struct qlcnic_eswitch {
 #define DEFAULT_MAC_LEARN	1
 
 #define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan <= MAX_VLAN_ID)
-#define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW \
-							&& (bw % 100) == 0)
+#define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW)
 #define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
 #define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
 #define IS_VALID_MODE(mode)	(mode == 0 || mode == 1)
-- 
1.6.0.2

