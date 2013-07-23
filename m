From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/4 v2] bonding: Fixed up a error "do not initialise statics
 to 0 or NULL" in bond_main.c
Date: Tue, 23 Jul 2013 15:25:47 +0800
Message-ID: <51EE2FFB.5040600@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:40131 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576Ab3GWH0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 03:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error is found by the checkpatch.pl tools.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5eb75ef..8ca04cb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -106,7 +106,7 @@ static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
 static char *arp_validate;
 static char *arp_all_targets;
 static char *fail_over_mac;
-static int all_slaves_active = 0;
+static int all_slaves_active;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 
-- 
1.8.0
