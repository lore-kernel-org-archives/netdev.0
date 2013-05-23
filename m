From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Fix misplaced empty line
Date: Thu, 23 May 2013 14:11:26 -0700
Message-ID: <1369343487-6453-6-git-send-email-nsujir@broadcom.com>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1136 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758563Ab3EWVLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 17:11:41 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 98b770e..bef3005 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1311,8 +1311,8 @@ static int tg3_phy_toggle_auxctl_smdsp(struct tg3 *tp, bool enable)
 
 	if (err)
 		return err;
-	if (enable)
 
+	if (enable)
 		val |= MII_TG3_AUXCTL_ACTL_SMDSP_ENA;
 	else
 		val &= ~MII_TG3_AUXCTL_ACTL_SMDSP_ENA;
-- 
1.8.1.4
