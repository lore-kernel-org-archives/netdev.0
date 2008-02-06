From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii matching table
Date: Wed,  6 Feb 2008 13:21:59 +0100
Message-ID: <1202300519-7294-1-git-send-email-sr@denx.de>
Cc: netdev@vger.kernel.org, jwboyer@linux.vnet.ibm.com,
	benh@kernel.crashing.org, linuxppc-dev@ozlabs.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:58206 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760155AbYBFMWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 07:22:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal the the "rgmii-interface" device_type property from the
dts files, the newemac driver needs an update to only rely on compatible
property.

Signed-off-by: Stefan Roese <sr@denx.de>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
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

