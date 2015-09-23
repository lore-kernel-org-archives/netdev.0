From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: [PATCH] net/ibm/emac: bump version numbers for correct work with
 ethtool
Date: Wed, 23 Sep 2015 14:42:22 +0400
Message-ID: <20150923144222.66de305c@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:49804 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381AbbIWLlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:41:46 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ivan@ru.ibm.com>;
	Wed, 23 Sep 2015 12:41:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register dump out work preventing with 
old ethtool + new driver and new ethtool + old driver.

---
 drivers/net/ethernet/ibm/emac/core.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 28df374..ac02c67 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -460,8 +460,8 @@ struct emac_ethtool_regs_subhdr {
 	u32 index;
 };
 
-#define EMAC_ETHTOOL_REGS_VER		0
-#define EMAC4_ETHTOOL_REGS_VER		1
-#define EMAC4SYNC_ETHTOOL_REGS_VER	2
+#define EMAC_ETHTOOL_REGS_VER		3
+#define EMAC4_ETHTOOL_REGS_VER		4
+#define EMAC4SYNC_ETHTOOL_REGS_VER	5
 
 #endif /* __IBM_NEWEMAC_CORE_H */
-- 
1.7.9.5
