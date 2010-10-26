From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] qlcnic: define valid vlan id range
Date: Tue, 26 Oct 2010 02:38:01 -0700
Message-ID: <1288085882-11988-4-git-send-email-amit.salecha@qlogic.com>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1530 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755194Ab0JZJiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 05:38:04 -0400
In-Reply-To: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

4095 vlan id is reserved and should not be use.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 6400e6a..8ecc170 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1134,7 +1134,7 @@ struct qlcnic_eswitch {
 #define MAX_RX_QUEUES		4
 #define DEFAULT_MAC_LEARN	1
 
-#define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan <= MAX_VLAN_ID)
+#define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan < MAX_VLAN_ID)
 #define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW)
 #define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
 #define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
-- 
1.6.0.2

