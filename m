From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] team: add macro MODULE_ALIAS_TEAM_MODE for team mode alias
Date: Thu,  1 Jun 2017 15:37:02 +0800
Message-ID: <1496302622-9958-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:54032 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdFAHhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 03:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new macro MODULE_ALIAS_TEAM_MODE to unify and simplify the
declaration of team mode alias.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/team/team_mode_activebackup.c | 2 +-
 drivers/net/team/team_mode_broadcast.c    | 2 +-
 drivers/net/team/team_mode_loadbalance.c  | 2 +-
 drivers/net/team/team_mode_random.c       | 2 +-
 drivers/net/team/team_mode_roundrobin.c   | 2 +-
 include/linux/if_team.h                   | 2 ++
 6 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 3f18982..ddd16a0 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -146,4 +146,4 @@ static void __exit ab_cleanup_module(void)
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
 MODULE_DESCRIPTION("Active-backup mode for team");
-MODULE_ALIAS("team-mode-activebackup");
+MODULE_ALIAS_TEAM_MODE("activebackup");
diff --git a/drivers/net/team/team_mode_broadcast.c b/drivers/net/team/team_mode_broadcast.c
index 302ff35..e4eac3d 100644
--- a/drivers/net/team/team_mode_broadcast.c
+++ b/drivers/net/team/team_mode_broadcast.c
@@ -75,4 +75,4 @@ static void __exit bc_cleanup_module(void)
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
 MODULE_DESCRIPTION("Broadcast mode for team");
-MODULE_ALIAS("team-mode-broadcast");
+MODULE_ALIAS_TEAM_MODE("broadcast");
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index b228bea..1468ddf 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -695,4 +695,4 @@ static void __exit lb_cleanup_module(void)
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
 MODULE_DESCRIPTION("Load-balancing mode for team");
-MODULE_ALIAS("team-mode-loadbalance");
+MODULE_ALIAS_TEAM_MODE("loadbalance");
diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index 215f845..c20b944 100644
--- a/drivers/net/team/team_mode_random.c
+++ b/drivers/net/team/team_mode_random.c
@@ -65,4 +65,4 @@ static void __exit rnd_cleanup_module(void)
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
 MODULE_DESCRIPTION("Random mode for team");
-MODULE_ALIAS("team-mode-random");
+MODULE_ALIAS_TEAM_MODE("random");
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 0aa2341..66c3209 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -77,4 +77,4 @@ static void __exit rr_cleanup_module(void)
 MODULE_LICENSE("GPL v2");
 MODULE_AUTHOR("Jiri Pirko <jpirko@redhat.com>");
 MODULE_DESCRIPTION("Round-robin mode for team");
-MODULE_ALIAS("team-mode-roundrobin");
+MODULE_ALIAS_TEAM_MODE("roundrobin");
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index c05216a..3029460 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -298,4 +298,6 @@ extern void team_options_unregister(struct team *team,
 #define TEAM_DEFAULT_NUM_TX_QUEUES 16
 #define TEAM_DEFAULT_NUM_RX_QUEUES 16
 
+#define MODULE_ALIAS_TEAM_MODE(kind) MODULE_ALIAS("team-mode-" kind)
+
 #endif /* _LINUX_IF_TEAM_H_ */
-- 
1.8.3.1
