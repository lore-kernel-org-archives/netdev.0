From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: caif: Remove unused stats member from struct chnl_net
Date: Thu, 19 Jan 2017 16:04:25 +0100
Message-ID: <20170119150425.12559-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:58120 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751530AbdASPRy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 10:17:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stats member of struct chnl_net is used nowhere in the code, so it
might as well be removed.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/caif/chnl_net.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 3408ed51b611..1816fc9f1ee7 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -44,7 +44,6 @@ enum caif_states {
 
 struct chnl_net {
 	struct cflayer chnl;
-	struct net_device_stats stats;
 	struct caif_connect_request conn_req;
 	struct list_head list_field;
 	struct net_device *netdev;
-- 
2.11.0
