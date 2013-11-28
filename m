From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/8] atm: idt77252: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:40:31 +0900
Message-ID: <004901ceebeb$96c26fd0$c4474f70$%han@samsung.com>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>,
	'Ying Xue' <ying.xue@windriver.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:42472 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab3K1Dkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:40:33 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY003ZUFJK6C40@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:40:32 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/idt77252.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 1bdf104..0f9fc76 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3730,7 +3730,7 @@ err_out_disable_pdev:
 	return err;
 }
 
-static struct pci_device_id idt77252_pci_tbl[] =
+static DEFINE_PCI_DEVICE_TABLE(idt77252_pci_tbl) =
 {
 	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77252), 0 },
 	{ 0, }
-- 
1.7.10.4
