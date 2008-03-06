From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu,  6 Mar 2008 11:55:46 +0100
Message-ID: <1204800947-21569-9-git-send-email-jonas@southpole.se>
References: <>
 <1204800947-21569-1-git-send-email-jonas@southpole.se>
 <1204800947-21569-2-git-send-email-jonas@southpole.se>
 <1204800947-21569-3-git-send-email-jonas@southpole.se>
 <1204800947-21569-4-git-send-email-jonas@southpole.se>
 <1204800947-21569-5-git-send-email-jonas@southpole.se>
 <1204800947-21569-6-git-send-email-jonas@southpole.se>
 <1204800947-21569-7-git-send-email-jonas@southpole.se>
 <1204800947-21569-8-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44122 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbYCFKzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 8FC2B4ED102
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:49 +0100 (CET)
In-Reply-To: <1204800947-21569-8-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes struct pci_device_id array const and adds section attribute __devinitconst

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0991648..542e0fa 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -53,7 +53,7 @@ static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation
   #define PCIE(x) x,
 #endif
 
-static struct pci_device_id e1000_pci_tbl[] = {
+static DECLARE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
 	INTEL_E1000_ETHERNET_DEVICE(0x1004),
-- 
1.5.4.3


