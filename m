From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] [net] use PCI_DEVICE_TABLE: makes struct pci_device_id array const and adds section attribute __devinitconst
Date: Wed, 20 Feb 2008 13:53:47 +0100
Message-ID: <1203512031-14318-12-git-send-email-jonas@southpole.se>
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
Cc: greg@kroah.com, Jonas Bonn <jonas@southpole.se>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42409 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175AbYBTMx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:56 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id A29614ED110
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:55 +0100 (CET)
In-Reply-To: <1203512031-14318-11-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/wan/dscc4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index c6f26e2..16d3a4c 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2048,7 +2048,7 @@ static int __init dscc4_setup(char *str)
 __setup("dscc4.setup=", dscc4_setup);
 #endif
 
-static struct pci_device_id dscc4_pci_tbl[] = {
+static PCI_DEVICE_TABLE(dscc4_pci_tbl) = {
 	{ PCI_VENDOR_ID_SIEMENS, PCI_DEVICE_ID_SIEMENS_DSCC4,
 	        PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
-- 
1.5.3.8


