From: Lightweight patch manager <patch@luckynet.dynu.com>
Subject: [PATCH][2.5] list_move_tail for sunrpc (1 occ)
Date: Sun, 9 Jun 2002 09:04:15 -0600 (MDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <advqu5$e04$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Team <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Linux Network <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

This patch introduces the new list_move_tail macro for the sunrpc driver
(net/sunrpc/svcsock.c)

--- linus-2.5/net/sunrpc/svcsock.c	Sun Jun  9 04:17:42 2002
+++ thunder-2.5/net/sunrpc/svcsock.c	Sun Jun  9 07:43:53 2002
@@ -1065,8 +1065,7 @@
 	if (test_bit(SK_TEMP, &svsk->sk_flags)) {
 		/* push active sockets to end of list */
 		spin_lock_bh(&serv->sv_lock);
-		list_del(&svsk->sk_list);
-		list_add_tail(&svsk->sk_list, &serv->sv_tempsocks);
+		list_move_tail(&svsk->sk_list, &serv->sv_tempsocks);
 		spin_unlock_bh(&serv->sv_lock);
 	}
 

-- 
Lightweight patch manager using pine. If you have any objections, tell me.
