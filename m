From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix ad_select module param check
Date: Sun, 13 Jul 2014 09:47:47 +0200
Message-ID: <1405237667-17531-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbaGMHsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2014 03:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obvious copy/paste error when I converted the ad_select to the new
option API. "lacp_rate" there should be "ad_select" so we can get the
proper value.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Fixes: 9e5f5eebe765 ("bonding: convert ad_select to use the new option
API")
Reported-by: Karim Scheik <karim.scheik@prisma-solutions.at>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3a451b6cd3d5..701f86cd5993 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4068,7 +4068,7 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (ad_select) {
-		bond_opt_initstr(&newval, lacp_rate);
+		bond_opt_initstr(&newval, ad_select);
 		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_AD_SELECT),
 					&newval);
 		if (!valptr) {
-- 
1.9.3
