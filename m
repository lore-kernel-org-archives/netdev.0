From: Li Yang <leoli@freescale.com>
Subject: [PATCH 1/2] ucc_geth: Fix MODULE_DEVICE_TABLE() duplication
Date: Tue, 22 May 2007 20:24:37 +0800
Message-ID: <4652E105.70806@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:60080 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944AbXEVMW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 08:22:58 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l4MCMttL015390
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 05:22:56 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l4MCMrLJ002968
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 07:22:54 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix MODULE_DEVICE_TABLE() duplication in ucc_geth.c and ucc_geth_mii.c
for ucc_geth to be compiled as module.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth_mii.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index f96966d..7bcb82f 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -260,8 +260,6 @@ static struct of_device_id uec_mdio_match[] = {
 	{},
 };
 
-MODULE_DEVICE_TABLE(of, uec_mdio_match);
-
 static struct of_platform_driver uec_mdio_driver = {
 	.name	= DRV_NAME,
 	.probe	= uec_mdio_probe,

