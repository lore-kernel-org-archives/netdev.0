From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/2] irda: donauboe: Remove casting the return value which is a
 void pointer
Date: Mon, 09 Sep 2013 14:22:19 +0900
Message-ID: <004b01cead1c$8e1678d0$aa436a70$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:46355 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab3IIFWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 01:22:25 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSU00EJMEX7D020@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Sep 2013 14:22:19 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting the return value which is a void pointer is redundant.
The conversion from void pointer to any other pointer type is
guaranteed by the C programming language.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/donauboe.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index c6bfc4a..bef2243 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1488,7 +1488,7 @@ static void
 toshoboe_close (struct pci_dev *pci_dev)
 {
   int i;
-  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
+  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
 
   IRDA_DEBUG (4, "%s()\n", __func__);
 
@@ -1696,7 +1696,7 @@ freeself:
 static int
 toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
 {
-  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
+  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
   unsigned long flags;
   int i = 10;
 
@@ -1725,7 +1725,7 @@ toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
 static int
 toshoboe_wakeup (struct pci_dev *pci_dev)
 {
-  struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
+  struct toshoboe_cb *self = pci_get_drvdata(pci_dev);
   unsigned long flags;
 
   IRDA_DEBUG (4, "%s()\n", __func__);
-- 
1.7.10.4
