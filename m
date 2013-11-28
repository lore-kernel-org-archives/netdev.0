From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/8] atm: he: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 12:39:41 +0900
Message-ID: <004801ceebeb$78a58b40$69f0a1c0$%han@samsung.com>
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
Received: from mailout4.samsung.com ([203.254.224.34]:55565 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934Ab3K1Djm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 22:39:42 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWY00ILNFI5Z640@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 28 Nov 2013 12:39:41 +0900 (KST)
In-reply-to: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This macro is used to create a struct pci_device_id array.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/he.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 8557adc..1adb17b 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2851,7 +2851,7 @@ MODULE_PARM_DESC(irq_coalesce, "use interrupt coalescing (default 1)");
 module_param(sdh, bool, 0);
 MODULE_PARM_DESC(sdh, "use SDH framing (default 0)");
 
-static struct pci_device_id he_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(he_pci_tbl) = {
 	{ PCI_VDEVICE(FORE, PCI_DEVICE_ID_FORE_HE), 0 },
 	{ 0, }
 };
-- 
1.7.10.4
