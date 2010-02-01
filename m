From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/7] qlcnic: use DEFINE_PCI_DEVICE_TABLE
Date: Mon,  1 Feb 2010 07:24:54 -0800
Message-ID: <1265037900-20403-2-git-send-email-amit.salecha@qlogic.com>
References: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11617 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755085Ab0BAPZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 10:25:03 -0500
In-Reply-To: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into
correct section in every case.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 1698b6a..05275f2 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -102,7 +102,7 @@ static void qlcnic_config_indev_addr(struct net_device *dev, unsigned long);
 
 #define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
 
-static const struct pci_device_id qlcnic_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	{0,}
 };
-- 
1.6.0.2

