From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] bonding/bond_main.c: fix cut'n'paste error
Date: Wed, 24 Oct 2007 18:27:43 +0200
Message-ID: <20071024162743.GV30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:32802 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760541AbXJXQ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:27:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a cut'n'paste error in
commit 1b76b31693d4a6088dec104ff6a6ead54081a3c2.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
4888742f8d7fe3b97fbc2911aa46375048173d01 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e5fab4b..6937ef0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3682,7 +3682,7 @@ static int bond_open(struct net_device *bond_dev)
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		INIT_DELAYED_WORK(&bond->ad_work, bond_alb_monitor);
+		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);

