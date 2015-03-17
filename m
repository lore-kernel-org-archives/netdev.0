From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 01/16 linux-next] net: netcp: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:32 +0100
Message-ID: <1426617469-781-2-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:46748 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753002AbbCQSiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:38:08 -0400
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/ti/netcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 9f14d8b..1c4dd80 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2127,7 +2127,7 @@ static int netcp_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id of_match[] = {
+static const struct of_device_id of_match[] = {
 	{ .compatible = "ti,netcp-1.0", },
 	{},
 };
-- 
2.1.0
