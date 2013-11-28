From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 6/8] atm: lanai: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:41:41 +0900
Message-ID: <004b01ceebeb$bffb9160$3ff2b420$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:64493 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758631Ab3K1Dlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:41:42 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00FR2FLHER50@mailout2.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:41:41 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/lanai.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index fa7d701..1e43693 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2601,7 +2601,7 @@ static int lanai_init_one(struct pci_dev *pci,
 	return result;
 }
 
-static struct pci_device_id lanai_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(lanai_pci_tbl) = {
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAI2) },
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAIHB) },
 	{ 0, }	/* terminal entry */
-- 
1.7.10.4
