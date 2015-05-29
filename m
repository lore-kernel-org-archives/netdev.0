From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/16] batman-adv: Makefile, Sort alphabetically
Date: Fri, 29 May 2015 11:05:19 +0200
Message-ID: <1432890328-8247-8-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:5371 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755675AbbE2JVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:21:25 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

The whole Makefile is sorted, just the multicast rule is not at the
right position.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index bd7e343..21434ab 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -29,6 +29,7 @@ batman-adv-y += hard-interface.o
 batman-adv-y += hash.o
 batman-adv-y += icmp_socket.o
 batman-adv-y += main.o
+batman-adv-$(CONFIG_BATMAN_ADV_MCAST) += multicast.o
 batman-adv-$(CONFIG_BATMAN_ADV_NC) += network-coding.o
 batman-adv-y += originator.o
 batman-adv-y += routing.o
@@ -36,4 +37,3 @@ batman-adv-y += send.o
 batman-adv-y += soft-interface.o
 batman-adv-y += sysfs.o
 batman-adv-y += translation-table.o
-batman-adv-$(CONFIG_BATMAN_ADV_MCAST) += multicast.o
-- 
2.4.2
