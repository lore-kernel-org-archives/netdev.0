From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu,  6 Mar 2008 11:55:42 +0100
Message-ID: <1204800947-21569-5-git-send-email-jonas@southpole.se>
References: <>
 <1204800947-21569-1-git-send-email-jonas@southpole.se>
 <1204800947-21569-2-git-send-email-jonas@southpole.se>
 <1204800947-21569-3-git-send-email-jonas@southpole.se>
 <1204800947-21569-4-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44127 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763659AbYCFKzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id D51A7A02AE
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:48 +0100 (CET)
In-Reply-To: <1204800947-21569-4-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes struct pci_device_id array const and moves it to __devinitconst

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/wan/pc300_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 57914fb..df62fef 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -252,7 +252,7 @@ static char rcsid[] =
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
 
-static struct pci_device_id cpc_pci_dev_id[] __devinitdata = {
+static DECLARE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
 	/* PC300/RSV or PC300/X21, 2 chan */
 	{0x120e, 0x300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x300},
 	/* PC300/RSV or PC300/X21, 1 chan */
-- 
1.5.4.3


