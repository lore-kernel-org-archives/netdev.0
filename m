From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 09/15] be2net: Allow VFs to call
 be_cmd_reset_function.
Date: Fri, 11 Feb 2011 17:36:57 -0600
Message-ID: <20110211233657.GA18423@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51225 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757767Ab1BKXhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:37:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f2d2036..8975340 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2959,11 +2959,9 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto ctrl_clean;
 
-	if (be_physfn(adapter)) {
-		status = be_cmd_reset_function(adapter);
-		if (status)
-			goto ctrl_clean;
-	}
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		goto ctrl_clean;
 
 	status = be_stats_init(adapter);
 	if (status)
-- 
1.7.1

