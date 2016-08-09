From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] bonding: fix the typo
Date: Tue,  9 Aug 2016 21:36:04 +0800
Message-ID: <1470749764-5666-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.118.58.43] ([123.118.58.43]:36050 "EHLO mail.rain.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932276AbcHINp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 09:45:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

The message "803.ad" should be "802.3ad".

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1f276fa..217e8da 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -152,7 +152,7 @@ module_param(lacp_rate, charp, 0);
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner; "
 			    "0 for slow, 1 for fast");
 module_param(ad_select, charp, 0);
-MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic; "
+MODULE_PARM_DESC(ad_select, "802.3ad aggregation selection logic; "
 			    "0 for stable (default), 1 for bandwidth, "
 			    "2 for count");
 module_param(min_links, int, 0);
-- 
2.7.4
