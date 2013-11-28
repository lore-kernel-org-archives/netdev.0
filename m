From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/8] atm: eni: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:37:25 +0900
Message-ID: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55130 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab3K1Dh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:37:27 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00L8XFEE9T20@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:37:26 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/eni.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index b1955ba..846fc9e 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2283,7 +2283,7 @@ err_disable:
 }
 
 
-static struct pci_device_id eni_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(eni_pci_tbl) = {
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_FPGA), 0 /* FPGA */ },
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_ASIC), 1 /* ASIC */ },
 	{ 0, }
-- 
1.7.10.4
