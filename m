From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/3] team: remove unuset rcu_head field from team_port struct
Date: Tue, 26 Jun 2012 18:52:47 +0200
Message-ID: <1340729567-3164-4-git-send-email-jpirko@redhat.com>
References: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758499Ab2FZRH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 13:07:29 -0400
In-Reply-To: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_team.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index e636a54..99efd60 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -60,7 +60,6 @@ struct team_port {
 		unsigned int mtu;
 	} orig;
 
-	struct rcu_head rcu;
 	long mode_priv[0];
 };
 
-- 
1.7.10.4
