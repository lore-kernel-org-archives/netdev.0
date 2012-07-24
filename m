From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: init error value to 0 in team_netpoll_setup()
Date: Tue, 24 Jul 2012 13:20:48 +0200
Message-ID: <1343128848-1284-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46667 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab2GXLUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:20:54 -0400
Received: by wgbdr13 with SMTP id dr13so6815888wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:20:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will ensure correct value is returned in case the port list is empty.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index b104c05..87707ab 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1447,7 +1447,7 @@ static int team_netpoll_setup(struct net_device *dev,
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
-	int err;
+	int err = 0;
 
 	mutex_lock(&team->lock);
 	list_for_each_entry(port, &team->port_list, list) {
-- 
1.7.10.4
