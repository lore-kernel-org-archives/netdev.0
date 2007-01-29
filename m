From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Remove noisy debug message
Date: Mon, 29 Jan 2007 01:00:30 +0000 (GMT)
Message-ID: <20070129010030.BB7A37B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:2517 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933029AbXA2BAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 20:00:25 -0500
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This causes a lot of uninteresting output in noisy environments, and
doesn't really serve any purpose.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_mac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1114,8 +1114,6 @@ static void zd_mac_rx(struct zd_mac *mac
 	{
 		ieee->stats.rx_errors++;
 		ieee->stats.rx_length_errors++;
-		dev_dbg_f(zd_mac_dev(mac), "Packet with length %u to small.\n",
-			 skb->len);
 		goto free_skb;
 	}
 
