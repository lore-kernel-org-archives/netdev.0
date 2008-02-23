From: Laura Garcia <nevola@gmail.com>
Subject: [PATCH 1/2]via-rhine.c: Use-register-offset-definition-for-WOLcgClr
Date: Sat, 23 Feb 2008 18:56:35 +0100
Message-ID: <E1JSybz-0004BD-Tu@elite>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:63916 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbYBWR4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 12:56:41 -0500
Received: by ug-out-1314.google.com with SMTP id z38so205295ugc.16
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 09:56:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use register offset definition for WOLcgClr. This patch does not 
change the driver behaviour.

Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>

	modified:   drivers/net/via-rhine.c
---
 drivers/net/via-rhine.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 7c851b1..8c9d6ae 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1893,7 +1893,7 @@ static void rhine_shutdown (struct pci_dev *pdev)
 
 	/* Make sure we use pattern 0, 1 and not 4, 5 */
 	if (rp->quirks & rq6patterns)
-		iowrite8(0x04, ioaddr + 0xA7);
+		iowrite8(0x04, ioaddr + WOLcgClr);
 
 	if (rp->wolopts & WAKE_MAGIC) {
 		iowrite8(WOLmagic, ioaddr + WOLcrSet);
-- 
1.5.3.8

