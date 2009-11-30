From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 2/6] be2net: initialize netdev->perm_addr
Date: Mon, 30 Nov 2009 09:25:39 +0530
Message-ID: <20091130035530.GA15468@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29459 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752761AbZK3Dza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:55:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch to initialize netdev->perm_addr

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 2c84c92..e24f498 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2147,6 +2147,7 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
+	memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
 
 	return 0;
 }
-- 
1.6.3.3

