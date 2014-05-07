From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 3/3] bonding: remove the unused macro
Date: Wed, 7 May 2014 22:02:39 +0800
Message-ID: <1399471359-5120-4-git-send-email-dingtianhong@huawei.com>
References: <1399471359-5120-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:3842 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaEGODR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 10:03:17 -0400
In-Reply-To: <1399471359-5120-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5d1e1a8..f462f6f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -182,8 +182,6 @@ struct bond_parm_tbl {
 	int mode;
 };
 
-#define BOND_MAX_MODENAME_LEN 20
-
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct bonding *bond; /* our master */
-- 
1.8.0
