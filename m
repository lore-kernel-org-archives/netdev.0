From: akpm@linux-foundation.org
Subject: [patch 06/13] fec_mpc52xx: MPC52xx_MESSAGES_DEFAULT: 2nd NETIF_MSG_IFDOWN => IFUP
Date: Mon, 09 Jun 2008 16:33:51 -0700
Message-ID: <200806092333.m59NXpvs014683@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com, grant.likely@secretlab.ca, tnt@246tNt.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53581 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756707AbYFIXeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Duplicate NETIF_MSG_IFDOWN, 2nd should be NETIF_MSG_IFUP

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Acked-by: Sylvain Munaut <tnt@246tNt.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/fec_mpc52xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/fec_mpc52xx.c~fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup drivers/net/fec_mpc52xx.c
--- a/drivers/net/fec_mpc52xx.c~fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup
+++ a/drivers/net/fec_mpc52xx.c
@@ -78,7 +78,7 @@ module_param_array_named(mac, mpc52xx_fe
 MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
 
 #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
-		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFDOWN )
+		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
 static int debug = -1;	/* the above default */
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "debugging messages level");
_
