From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] [net] use PCI_DEVICE_TABLE: makes struct pci_device_id array const and adds section attribute __devinitconst
Date: Wed, 20 Feb 2008 13:53:48 +0100
Message-ID: <1203512031-14318-13-git-send-email-jonas@southpole.se>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se>
 <1203512031-14318-2-git-send-email-jonas@southpole.se>
 <1203512031-14318-3-git-send-email-jonas@southpole.se>
 <1203512031-14318-4-git-send-email-jonas@southpole.se>
 <1203512031-14318-5-git-send-email-jonas@southpole.se>
 <1203512031-14318-6-git-send-email-jonas@southpole.se>
 <1203512031-14318-7-git-send-email-jonas@southpole.se>
 <1203512031-14318-8-git-send-email-jonas@southpole.se>
 <1203512031-14318-9-git-send-email-jonas@southpole.se>
 <1203512031-14318-10-git-send-email-jonas@southpole.se>
 <1203512031-14318-11-git-send-email-jonas@southpole.se>
 <1203512031-14318-12-git-send-email-jonas@southpole.se>
Cc: greg@kroah.com, Jonas Bonn <jonas@southpole.se>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42426 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757073AbYBTMx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 20B6F4ED0FE
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:54 +0100 (CET)
In-Reply-To: <1203512031-14318-12-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/wan/lmc/lmc_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 6635ece..e85cfe7 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -82,7 +82,7 @@ static int lmc_first_load = 0;
 
 static int LMC_PKT_BUF_SZ = 1542;
 
-static struct pci_device_id lmc_pci_tbl[] = {
+static PCI_DEVICE_TABLE(lmc_pci_tbl) = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
 	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
-- 
1.5.3.8


