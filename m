From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/12] tg3: Make 57791 and 57795 10/100 only
Date: Wed, 17 Feb 2010 17:16:55 -0800
Message-ID: <1266455825-16150-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3085 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561Ab0BRBRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 57791 and 57795 to the list of devices that only
support 10 and 100 Mbps speeds.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 344490e..051b18a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13588,6 +13588,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F ||
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5787F)) ||
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57791 ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57795 ||
 	    (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET))
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
-- 
1.6.4.4


