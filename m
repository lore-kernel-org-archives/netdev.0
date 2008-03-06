From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] net: use DECLARE_PCI_DEVICE_TABLE
Date: Thu,  6 Mar 2008 11:55:40 +0100
Message-ID: <1204800947-21569-3-git-send-email-jonas@southpole.se>
References: <>
 <1204800947-21569-1-git-send-email-jonas@southpole.se>
 <1204800947-21569-2-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44121 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761327AbYCFKzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:51 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 007214ED0FA
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:47 +0100 (CET)
In-Reply-To: <1204800947-21569-2-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes struct pci_device_id array const and moves it to __devinitconst

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9737eae..7eaff19 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -73,7 +73,7 @@ static irqreturn_t netxen_intr(int irq, void *data);
 int physical_port[] = {0, 1, 2, 3};
 
 /*  PCI Device ID Table  */
-static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
+static DECLARE_PCI_DEVICE_TABLE(netxen_pci_tbl) = {
 	{PCI_DEVICE(0x4040, 0x0001)},
 	{PCI_DEVICE(0x4040, 0x0002)},
 	{PCI_DEVICE(0x4040, 0x0003)},
-- 
1.5.4.3


