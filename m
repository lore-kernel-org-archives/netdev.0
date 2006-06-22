From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 14/32] [TIPC] Non-operation-affecting corrections to comments & function definitions.
Date: Thu, 22 Jun 2006 15:59:27 +0200
Message-ID: <11509847863258-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:35734 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030649AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index eaf4d69..0923213 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -437,7 +437,7 @@ static int dest_name_check(struct sockad
  * @iocb: (unused)
  * @sock: socket structure
  * @m: message to send
- * @total_len: (unused)
+ * @total_len: length of message
  * 
  * Message must have an destination specified explicitly.
  * Used for SOCK_RDM and SOCK_DGRAM messages, 
@@ -538,7 +538,7 @@ exit:                                
  * @iocb: (unused)
  * @sock: socket structure
  * @m: message to send
- * @total_len: (unused)
+ * @total_len: length of message
  * 
  * Used for SOCK_SEQPACKET messages and SOCK_STREAM data.
  * 
@@ -1386,7 +1386,7 @@ exit:
 /**
  * shutdown - shutdown socket connection
  * @sock: socket structure
- * @how: direction to close (always treated as read + write)
+ * @how: direction to close (unused; always treated as read + write)
  *
  * Terminates connection (if necessary), then purges socket's receive queue.
  * 
@@ -1469,7 +1469,8 @@ restart:
  * Returns 0 on success, errno otherwise
  */
 
-static int setsockopt(struct socket *sock, int lvl, int opt, char *ov, int ol)
+static int setsockopt(struct socket *sock, 
+		      int lvl, int opt, char __user *ov, int ol)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 	u32 value;
@@ -1525,7 +1526,8 @@ static int setsockopt(struct socket *soc
  * Returns 0 on success, errno otherwise
  */
 
-static int getsockopt(struct socket *sock, int lvl, int opt, char *ov, int *ol)
+static int getsockopt(struct socket *sock, 
+		      int lvl, int opt, char __user *ov, int *ol)
 {
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
         int len;
-- 
1.4.0

