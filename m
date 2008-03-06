From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu,  6 Mar 2008 11:55:39 +0100
Message-ID: <1204800947-21569-2-git-send-email-jonas@southpole.se>
References: <>
 <1204800947-21569-1-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44092 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760576AbYCFKzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:49 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id F088D4ED0F9
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:47 +0100 (CET)
In-Reply-To: <1204800947-21569-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes struct pci_device_id array const and moves it to __devinitconst

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/cassini.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 14299f8..1451533 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -233,7 +233,7 @@ static u16 link_modes[] __devinitdata = {
 	CAS_BMCR_SPEED1000|BMCR_FULLDPLX /* 5 : 1000bt full duplex */
 };
 
-static struct pci_device_id cas_pci_tbl[] __devinitdata = {
+static DECLARE_PCI_DEVICE_TABLE(cas_pci_tbl) = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,
-- 
1.5.4.3


