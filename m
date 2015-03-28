From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] bonding: Remove hardcoded initialization
Date: Fri, 27 Mar 2015 22:34:31 -0700
Message-ID: <1427520871-29869-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:34046 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbbC1Fef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:34:35 -0400
Received: by pdev10 with SMTP id v10so4436031pde.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:34:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3cce25818b57..48f3bd7e2350 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1776,7 +1776,7 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 
 		port->is_enabled = true;
 		/* private parameters */
-		port->sm_vars = 0x3;
+		port->sm_vars = AD_PORT_BEGIN | AD_PORT_LACP_ENABLED;
 		port->sm_rx_state = 0;
 		port->sm_rx_timer_counter = 0;
 		port->sm_periodic_state = 0;
-- 
2.2.0.rc0.207.ga3a616c
