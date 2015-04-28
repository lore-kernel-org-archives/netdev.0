From: Antonio Ospite <ao2@ao2.it>
Subject: [PATCH 10/12] trivial: net: systemport: bcmsysport.h: fix 0x0x prefix
Date: Tue, 28 Apr 2015 13:11:29 +0200
Message-ID: <1430219491-5076-11-git-send-email-ao2@ao2.it>
References: <1430219491-5076-1-git-send-email-ao2@ao2.it>
Cc: Antonio Ospite <ao2@ao2.it>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp207.alice.it ([82.57.200.103]:29355 "EHLO smtp207.alice.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964991AbbD1LRr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 07:17:47 -0400
In-Reply-To: <1430219491-5076-1-git-send-email-ao2@ao2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the 0x0x prefix in an integer constant.

In this case, while at it, also fix a typo (s/unitcast/unicast/).

Signed-off-by: Antonio Ospite <ao2@ao2.it>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bcmsysport.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 7e3d87a..e2c043e 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -543,7 +543,7 @@ struct bcm_sysport_tx_counters {
 	u32	jbr;		/* RO # of xmited jabber count*/
 	u32	bytes;		/* RO # of xmited byte count */
 	u32	pok;		/* RO # of xmited good pkt */
-	u32	uc;		/* RO (0x0x4f0)# of xmited unitcast pkt */
+	u32	uc;		/* RO (0x4f0) # of xmited unicast pkt */
 };
 
 struct bcm_sysport_mib {
-- 
2.1.4
