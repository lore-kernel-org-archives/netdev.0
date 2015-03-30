From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/7] ssb: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 10:43:21 -0700
Message-ID: <57da8293b865fb2d119e29073aec54323fc10000.1427736972.git.joe@perches.com>
References: <cover.1427736972.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0236.hostedemail.com ([216.40.44.236]:59691 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753868AbbC3Rnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:43:45 -0400
In-Reply-To: <cover.1427736972.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/ssb/driver_gige.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ssb/driver_gige.c b/drivers/ssb/driver_gige.c
index e973405..ebee6b0 100644
--- a/drivers/ssb/driver_gige.c
+++ b/drivers/ssb/driver_gige.c
@@ -242,7 +242,7 @@ static int ssb_gige_probe(struct ssb_device *sdev,
 bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
 {
 	if (!pdev->resource[0].name)
-		return 0;
+		return false;
 	return (strcmp(pdev->resource[0].name, SSB_GIGE_MEM_RES_NAME) == 0);
 }
 EXPORT_SYMBOL(pdev_is_ssb_gige_core);
-- 
2.1.2
