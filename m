From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/12] batman-adv: iv_ogm, fix comment function name
Date: Wed,  3 Jun 2015 16:14:02 +0200
Message-ID: <1433340848-1682-7-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:39634 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932617AbbFCOQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:20 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

This is a small copy paste fix for batadv_ing_buffer_avg.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0019f1b..9f83137 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -55,7 +55,7 @@ static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
 }
 
 /**
- * batadv_ring_buffer_set - compute the average of all non-zero values stored
+ * batadv_ring_buffer_avg - compute the average of all non-zero values stored
  * in the given ring buffer
  * @lq_recv: pointer to the ring buffer
  *
-- 
2.4.2
