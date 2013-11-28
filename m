From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 7/8] atm: nicstar: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:42:28 +0900
Message-ID: <004c01ceebeb$dc04b120$940e1360$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>,
	'Andy Shevchenko' <andriy.shevchenko@linux.intel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:25418 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab3K1Dm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:42:29 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00BDDFMSZNE0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:42:28 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/nicstar.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 5aca5f4..7353d41 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -260,7 +260,7 @@ static void nicstar_remove_one(struct pci_dev *pcidev)
 	kfree(card);
 }
 
-static struct pci_device_id nicstar_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(nicstar_pci_tbl) = {
 	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77201), 0 },
 	{0,}			/* terminate list */
 };
-- 
1.7.10.4
