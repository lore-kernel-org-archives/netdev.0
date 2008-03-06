From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu,  6 Mar 2008 11:55:45 +0100
Message-ID: <1204800947-21569-8-git-send-email-jonas@southpole.se>
References: <>
 <1204800947-21569-1-git-send-email-jonas@southpole.se>
 <1204800947-21569-2-git-send-email-jonas@southpole.se>
 <1204800947-21569-3-git-send-email-jonas@southpole.se>
 <1204800947-21569-4-git-send-email-jonas@southpole.se>
 <1204800947-21569-5-git-send-email-jonas@southpole.se>
 <1204800947-21569-6-git-send-email-jonas@southpole.se>
 <1204800947-21569-7-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44121 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760504AbYCFKzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id B8C52A02C0
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:49 +0100 (CET)
In-Reply-To: <1204800947-21569-7-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes struct pci_device_id array const and moves it to __devinitconst

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/wan/farsync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index cf27bf4..db68596 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -530,7 +530,7 @@ static int fst_debug_mask = { FST_DEBUG };
 /*
  *      PCI ID lookup table
  */
-static struct pci_device_id fst_pci_dev_id[] __devinitdata = {
+static DECLARE_PCI_DEVICE_TABLE(fst_pci_dev_id) = {
 	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID, 
 	 PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
 
-- 
1.5.4.3


