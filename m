From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: remove useless struct member
Date: Thu, 14 May 2009 23:45:04 +0200
Message-ID: <20090514214504.GA6374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vincent Steenhoute <vsteenhoute@novell.com>,
	Jean Delvare <jdelvare@suse.de>,
	Martin Michlmayr <tbm@cyrius.com>,
	Xose Vazquez Perez <xose.vazquez@gmail.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47039 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbZENVoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 17:44:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0b6e8c8..f86bf31 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -479,7 +479,6 @@ struct rtl8169_private {
 	u16 intr_event;
 	u16 napi_event;
 	u16 intr_mask;
-	int phy_auto_nego_reg;
 	int phy_1000_ctrl_reg;
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
@@ -908,7 +907,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		mdio_write(ioaddr, 0x0e, 0x0000);
 	}
 
-	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
 	mdio_write(ioaddr, MII_ADVERTISE, auto_nego);
-- 
1.6.0.6

