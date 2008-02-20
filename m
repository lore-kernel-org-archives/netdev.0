From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] [net] use PCI_DEVICE_TABLE: makes struct pci_device_id array const and adds section attribute __devinitconst
Date: Wed, 20 Feb 2008 13:53:46 +0100
Message-ID: <1203512031-14318-11-git-send-email-jonas@southpole.se>
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
Cc: greg@kroah.com, Jonas Bonn <jonas@southpole.se>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42411 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358AbYBTMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 0369C4ED108
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:55 +0100 (CET)
In-Reply-To: <1203512031-14318-10-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/sk98lin/skge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index 20890e4..eedcbeb 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -5166,7 +5166,7 @@ err_out:
 #define skge_resume NULL
 #endif
 
-static struct pci_device_id skge_pci_tbl[] = {
+static PCI_DEVICE_TABLE(skge_pci_tbl) = {
 #ifdef SK98LIN_ALL_DEVICES
 	{ PCI_VENDOR_ID_3COM, 0x1700, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_3COM, 0x80eb, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-- 
1.5.3.8


