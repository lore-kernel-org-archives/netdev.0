From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] net: socket: fix a typo in sockfd_lookup().
Date: Sun, 21 May 2017 22:12:38 +0300
Message-ID: <1495393958-9304-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:10027 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752119AbdEUTM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 15:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo in sockfd_lookup() in net/socket.c.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index cb355a7..8f9dab3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -461,7 +461,7 @@ EXPORT_SYMBOL(sock_from_file);
  *	@err: pointer to an error code return
  *
  *	The file handle passed in is locked and the socket it is bound
- *	too is returned. If an error occurs the err pointer is overwritten
+ *	to is returned. If an error occurs the err pointer is overwritten
  *	with a negative errno code and NULL is returned. The function checks
  *	for both invalid handles and passing a handle which is not a socket.
  *
-- 
2.7.4
