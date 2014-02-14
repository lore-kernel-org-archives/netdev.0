From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/4] appletalk: fix checkpatch errors with foo* bar|foo * bar
Date: Fri, 14 Feb 2014 15:43:44 +0800
Message-ID: <1392363826-8256-3-git-send-email-wangweidong1@huawei.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34082 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaBNHoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 02:44:21 -0500
In-Reply-To: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors below:
ERROR: "foo* bar" should be "foo *bar"
ERROR: "foo * bar" should be "foo *bar"

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/appletalk/ddp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index a878df9..06e0d19 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -293,7 +293,7 @@ static int atif_probe_device(struct atalk_iface *atif)
 
 /* Perform AARP probing for a proxy address */
 static int atif_proxy_probe_device(struct atalk_iface *atif,
-				   struct atalk_addr* proxy_addr)
+				   struct atalk_addr *proxy_addr)
 {
 	int netrange = ntohs(atif->nets.nr_lastnet) -
 			ntohs(atif->nets.nr_firstnet) + 1;
@@ -581,7 +581,7 @@ out:
 }
 
 /* Delete a route. Find it and discard it */
-static int atrtr_delete(struct atalk_addr * addr)
+static int atrtr_delete(struct atalk_addr *addr)
 {
 	struct atalk_route **r = &atalk_routes;
 	int retval = 0;
-- 
1.7.12
