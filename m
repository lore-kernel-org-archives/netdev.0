From: akpm@linux-foundation.org
Subject: [patch 5/8] net/atm/lec.c: drop code after return
Date: Mon, 22 Sep 2008 14:50:41 -0700
Message-ID: <200809222150.m8MLofR7031869@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	chas@cmf.nrl.navy.mil, richard.genoud@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60607 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753800AbYIVV5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The break after the return serves no purpose.

Signed-off-by: Julia Lawall <julia@diku.dk>
Reviewed-by: Richard Genoud <richard.genoud@gmail.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/lec.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN net/atm/lec.c~net-atm-lecc-drop-code-after-return net/atm/lec.c
--- a/net/atm/lec.c~net-atm-lecc-drop-code-after-return
+++ a/net/atm/lec.c
@@ -1931,7 +1931,6 @@ static struct atm_vcc *lec_arp_resolve(s
 		switch (priv->lane_version) {
 		case 1:
 			return priv->mcast_vcc;
-			break;
 		case 2:	/* LANE2 wants arp for multicast addresses */
 			if (!compare_ether_addr(mac_to_find, bus_mac))
 				return priv->mcast_vcc;
_
