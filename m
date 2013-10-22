From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/3] net: ksz884x: use DEFINE_PCI_DEVICE_TABLE
Date: Tue, 22 Oct 2013 12:01:47 +0900
Message-ID: <001001ceced3$0bbdea20$2339be60$%han@samsung.com>
References: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Lennert Buytenhek' <buytenh@wantstofly.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:27843 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3JVDBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 23:01:48 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV1002TGV2XNKH0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 12:01:47 +0900 (KST)
In-reply-to: <000e01ceced2$a9e5d970$fdb18c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 6462dc5..ddd252a 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7225,7 +7225,7 @@ static int pcidev_suspend(struct pci_dev *pdev, pm_message_t state)
 
 static char pcidev_name[] = "ksz884xp";
 
-static struct pci_device_id pcidev_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(pcidev_table) = {
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8841,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8842,
-- 
1.7.10.4
