From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Allow minimum bandwidth of zero
Date: Tue, 16 Nov 2010 16:07:53 -0800
Message-ID: <alpine.OSX.2.00.1011161511390.88679@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:19246 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375Ab0KQAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 19:08:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Allow minimum bandwidth to be set zero

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 8ecc170..a6b71fe 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1126,8 +1126,7 @@ struct qlcnic_eswitch {
 /* Return codes for Error handling */
 #define QL_STATUS_INVALID_PARAM	-1
 
-#define MAX_BW			100
-#define MIN_BW			1
+#define MAX_BW			100	/* % of link speed */
 #define MAX_VLAN_ID		4095
 #define MIN_VLAN_ID		2
 #define MAX_TX_QUEUES		1
@@ -1135,7 +1134,7 @@ struct qlcnic_eswitch {
 #define DEFAULT_MAC_LEARN	1
 
 #define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan < MAX_VLAN_ID)
-#define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW)
+#define IS_VALID_BW(bw)		(bw <= MAX_BW)
 #define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
 #define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
 
-- 
1.5.4.5

