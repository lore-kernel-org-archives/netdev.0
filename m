From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] [net] use PCI_DEVICE_TABLE: makes struct pci_device_id array const and adds section attribute __devinitconst
Date: Wed, 20 Feb 2008 13:53:43 +0100
Message-ID: <1203512031-14318-8-git-send-email-jonas@southpole.se>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se>
 <1203512031-14318-2-git-send-email-jonas@southpole.se>
 <1203512031-14318-3-git-send-email-jonas@southpole.se>
 <1203512031-14318-4-git-send-email-jonas@southpole.se>
 <1203512031-14318-5-git-send-email-jonas@southpole.se>
 <1203512031-14318-6-git-send-email-jonas@southpole.se>
 <1203512031-14318-7-git-send-email-jonas@southpole.se>
Cc: greg@kroah.com, Jonas Bonn <jonas@southpole.se>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42411 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756940AbYBTMxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:55 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id E11774ED107
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:53 +0100 (CET)
In-Reply-To: <1203512031-14318-7-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 6f8e7d4..d2045d4 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -372,7 +372,7 @@ static struct vortex_chip_info {
 };
 
 
-static struct pci_device_id vortex_pci_tbl[] = {
+static PCI_DEVICE_TABLE(vortex_pci_tbl) = {
 	{ 0x10B7, 0x5900, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C590 },
 	{ 0x10B7, 0x5920, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C592 },
 	{ 0x10B7, 0x5970, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C597 },
-- 
1.5.3.8


