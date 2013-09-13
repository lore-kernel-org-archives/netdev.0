From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: ps3_gelic: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:33:18 +0200
Message-ID: <1379046798-7192-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42952 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751173Ab3IMEd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 00:33:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/toshiba/ps3_gelic_net.c

It's a NOOP since 2.6.35 and I will remove it one day ;)

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 9c805e0..f7f2ef4 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1726,7 +1726,7 @@ static int ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 		goto fail_alloc_irq;
 	}
 	result = request_irq(card->irq, gelic_card_interrupt,
-			     IRQF_DISABLED, netdev->name, card);
+			     0, netdev->name, card);
 
 	if (result) {
 		dev_info(ctodev(card), "%s:request_irq failed (%d)\n",
-- 
1.8.1.2
