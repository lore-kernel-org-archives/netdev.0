From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 13/19] team: pass NULL to __team_option_inst_add() instead of 0
Date: Tue, 19 Jun 2012 17:54:15 +0200
Message-ID: <1340121261-2966-14-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab2FSPyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:45 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index da72f41..eb18ac9 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -164,7 +164,7 @@ static int __team_option_inst_add_option(struct team *team,
 	int err;
 
 	if (!option->per_port) {
-		err = __team_option_inst_add(team, option, 0);
+		err = __team_option_inst_add(team, option, NULL);
 		if (err)
 			goto inst_del_option;
 	}
-- 
1.7.10.2
