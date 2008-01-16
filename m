From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii matching table
Date: Wed, 16 Jan 2008 10:37:10 +0100
Message-ID: <1200476230-14026-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:59078 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYAPJhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 04:37:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal the the "rgmii-interface" device_type property from the
dts files, the newemac driver needs an update to only rely on compatible
property.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/rgmii.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
index 9bc1132..5757788 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -302,7 +302,6 @@ static int __devexit rgmii_remove(struct of_device *ofdev)
 static struct of_device_id rgmii_match[] =
 {
 	{
-		.type		= "rgmii-interface",
 		.compatible	= "ibm,rgmii",
 	},
 	{
-- 
1.5.4.rc3

