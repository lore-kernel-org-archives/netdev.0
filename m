From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/3] team: lb: let userspace care about port macs
Date: Fri, 20 Apr 2012 16:42:04 +0200
Message-ID: <1334932926-23996-2-git-send-email-jpirko@redhat.com>
References: <1334932926-23996-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881Ab2DTOmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 10:42:15 -0400
In-Reply-To: <1334932926-23996-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better to leave this for userspace

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_loadbalance.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 2b506b2..438d5b8 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -142,22 +142,10 @@ static void lb_exit(struct team *team)
 				ARRAY_SIZE(lb_options));
 }
 
-static int lb_port_enter(struct team *team, struct team_port *port)
-{
-	return team_port_set_team_mac(port);
-}
-
-static void lb_port_change_mac(struct team *team, struct team_port *port)
-{
-	team_port_set_team_mac(port);
-}
-
 static const struct team_mode_ops lb_mode_ops = {
 	.init			= lb_init,
 	.exit			= lb_exit,
 	.transmit		= lb_transmit,
-	.port_enter		= lb_port_enter,
-	.port_change_mac	= lb_port_change_mac,
 };
 
 static struct team_mode lb_mode = {
-- 
1.7.9.1
