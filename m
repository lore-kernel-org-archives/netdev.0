From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 6/9] qlcnic: Fix ethtool display for 83xx adapter.
Date: Fri, 19 Jul 2013 16:56:31 -0400
Message-ID: <1374267394-27697-7-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:43735 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Commit b938662d88264c1a92611ca1b82fdff5a4e87121
  ("qlcnic: Fix ethtool supported port status for 83xx")
  introduced regression for display of link status for 83xx
  adapter while refactoring port status display. This patch
  is to fix the link status display for 83xx adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 0913c62..bc483e1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3014,8 +3014,8 @@ int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter,
 	}
 
 	if (ahw->port_type == QLCNIC_XGBE) {
-		ecmd->supported = SUPPORTED_1000baseT_Full;
-		ecmd->advertising = ADVERTISED_1000baseT_Full;
+		ecmd->supported = SUPPORTED_10000baseT_Full;
+		ecmd->advertising = ADVERTISED_10000baseT_Full;
 	} else {
 		ecmd->supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
-- 
1.7.1
