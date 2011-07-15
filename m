From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 17/21] spider_net: do not mention dying vlan_hwaccel_receive_skb
Date: Fri, 15 Jul 2011 23:33:35 +0200
Message-ID: <1310765619-27827-18-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	kou.ishizaki@toshiba.co.jp, jens@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab1GOVe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:28 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/spider_net.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 9bc6c20..1ff3491c 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1004,9 +1004,7 @@ spider_net_pass_skb_up(struct spider_net_descr *descr,
 	}
 
 	if (data_status & SPIDER_NET_VLAN_PACKET) {
-		/* further enhancements: HW-accel VLAN
-		 * vlan_hwaccel_receive_skb
-		 */
+		/* further enhancements: HW-accel VLAN */
 	}
 
 	/* update netdevice statistics */
-- 
1.7.6

