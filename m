From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: NEWEMAC: Add compatible "ibm,tah" to tah matching table
Date: Thu, 13 Mar 2008 16:59:43 +0100
Message-ID: <1205423983-21142-1-git-send-email-sr@denx.de>
Cc: jwboyer@linux.vnet.ibm.com, benh@kernel.crashing.org
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61060 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbYCMP7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 11:59:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add "ibm,tah" to the compatible matching table of the ibm_newemac
tah driver. The type "tah" is still preserved for compatibility reasons.
New dts files should use the compatible property though.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/tah.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/tah.c
index 96417ad..b023d10 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -155,6 +155,10 @@ static int __devexit tah_remove(struct of_device *ofdev)
 static struct of_device_id tah_match[] =
 {
 	{
+		.compatible	= "ibm,tah",
+	},
+	/* For backward compat with old DT */
+	{
 		.type		= "tah",
 	},
 	{},
-- 
1.5.4.4

