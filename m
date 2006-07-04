From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [PKT_SCHED]: Return ENOENT if action module is unavailable
Date: Wed, 05 Jul 2006 00:00:02 +0200
Message-ID: <20060704220550.113899000@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch>
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56773 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932311AbWGDWGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:06:50 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=act_fix_init_ret_val
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/sched/act_api.c
===================================================================
--- net-2.6.git.orig/net/sched/act_api.c
+++ net-2.6.git/net/sched/act_api.c
@@ -305,6 +305,7 @@ struct tc_action *tcf_action_init_1(stru
 			goto err_mod;
 		}
 #endif
+		*err = -ENOENT;
 		goto err_out;
 	}
 

--

