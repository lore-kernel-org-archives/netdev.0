From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 25/32] [TIPC] Added missing warning for out-of-memory condition
Date: Thu, 22 Jun 2006 15:59:38 +0200
Message-ID: <11509847871687-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:37782 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030660AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/port.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 899e08e..99846a1 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1061,6 +1061,7 @@ int tipc_createport(u32 user_ref, 
 
 	up_ptr = (struct user_port *)kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
 	if (up_ptr == NULL) {
+		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
 	ref = tipc_createport_raw(NULL, port_dispatcher, port_wakeup, importance);
-- 
1.4.0

