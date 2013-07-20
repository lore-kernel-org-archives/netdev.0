From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/4] bonding: Fixed up a error "do not initialise statics
 to 0 or NULL" in bond_main.c
Date: Sat, 20 Jul 2013 15:23:53 +0800
Message-ID: <51EA3B09.2080006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45518 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3GTH1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 03:27:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error is found by the checkpatch.pl tools.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
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
