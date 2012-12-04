From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: neterion: use for_each_pci_dev to simplify the code
Date: Tue, 4 Dec 2012 00:05:13 -0500
Message-ID: <CAPgLHd-W5Lpa7EPFMit6Go+zt6ZrsV9dhEg9B2eQDxFCzau0Zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jdmason@kudzu.us, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:51483 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab2LDFFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 00:05:13 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so431641qad.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 21:05:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Use for_each_pci_dev to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/neterion/s2io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index c98decb..3b63504 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -1040,7 +1040,7 @@ static int s2io_verify_pci_mode(struct s2io_nic *nic)
 static int s2io_on_nec_bridge(struct pci_dev *s2io_pdev)
 {
 	struct pci_dev *tdev = NULL;
-	while ((tdev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) != NULL) {
+	for_each_pci_dev(tdev) {
 		if (tdev->vendor == NEC_VENID && tdev->device == NEC_DEVID) {
 			if (tdev->bus == s2io_pdev->bus->parent) {
 				pci_dev_put(tdev);
