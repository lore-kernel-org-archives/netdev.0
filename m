From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport move_addr_to_{kernel,user}
Date: Wed, 23 Apr 2008 12:51:45 +0300
Message-ID: <20080423095145.GB28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:46161 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755940AbYDWJwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 05:52:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the removal of the Solaris binary emulation the exports of 
move_addr_to_{kernel,user} are no longer used.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
a069421fb152fc48f13eab8b53b2eb3903ef8e8a diff --git a/net/socket.c b/net/socket.c
index 9b5c917..66c4a8c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2327,9 +2327,6 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 	return sock->ops->shutdown(sock, how);
 }
 
-/* ABI emulation layers need these two */
-EXPORT_SYMBOL(move_addr_to_kernel);
-EXPORT_SYMBOL(move_addr_to_user);
 EXPORT_SYMBOL(sock_create);
 EXPORT_SYMBOL(sock_create_kern);
 EXPORT_SYMBOL(sock_create_lite);

