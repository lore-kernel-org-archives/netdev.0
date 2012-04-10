From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 5/5] team: add missed "statics"
Date: Tue, 10 Apr 2012 17:15:46 +0200
Message-ID: <1334070946-7704-6-git-send-email-jpirko@redhat.com>
References: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758892Ab2DJPQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 11:16:00 -0400
In-Reply-To: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                   |    2 +-
 drivers/net/team/team_mode_activebackup.c |    4 ++--
 drivers/net/team/team_mode_loadbalance.c  |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index e639abe..153a62d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -65,7 +65,7 @@ static int __set_port_mac(struct net_device *port_dev,
 	return dev_set_mac_address(port_dev, &addr);
 }
 
-int team_port_set_orig_mac(struct team_port *port)
+static int team_port_set_orig_mac(struct team_port *port)
 {
 	return __set_port_mac(port->dev, port->orig.dev_addr);
 }
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index a715c40..fd6bd03 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -90,12 +90,12 @@ static const struct team_option ab_options[] = {
 	},
 };
 
-int ab_init(struct team *team)
+static int ab_init(struct team *team)
 {
 	return team_options_register(team, ab_options, ARRAY_SIZE(ab_options));
 }
 
-void ab_exit(struct team *team)
+static void ab_exit(struct team *team)
 {
 	team_options_unregister(team, ab_options, ARRAY_SIZE(ab_options));
 }
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 167cdb4..2b506b2 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -130,13 +130,13 @@ static const struct team_option lb_options[] = {
 	},
 };
 
-int lb_init(struct team *team)
+static int lb_init(struct team *team)
 {
 	return team_options_register(team, lb_options,
 				     ARRAY_SIZE(lb_options));
 }
 
-void lb_exit(struct team *team)
+static void lb_exit(struct team *team)
 {
 	team_options_unregister(team, lb_options,
 				ARRAY_SIZE(lb_options));
-- 
1.7.9.1
