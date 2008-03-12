From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] NPROTO is redundant; it's equal to AF_MAX/PF_MAX.
Date: Thu, 13 Mar 2008 10:50:13 +1100
Message-ID: <200803131050.13790.rusty@rustcorp.com.au>
References: <200803121224.25228.rusty@rustcorp.com.au> <200803121834.26493.rusty@rustcorp.com.au> <20080312.041318.193687381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45469 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700AbYCLXv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 19:51:26 -0400
In-Reply-To: <20080312.041318.193687381.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DaveM pointed out NPROTO exposed to userspace, so keep it around,
just make sure it stays in sync.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 1c65089f4c8f include/linux/net.h
--- a/include/linux/net.h	Wed Mar 12 11:19:20 2008 +1100
+++ b/include/linux/net.h	Wed Mar 12 12:21:46 2008 +1100
@@ -19,14 +19,15 @@
 #define _LINUX_NET_H
 
 #include <linux/wait.h>
+#include <linux/socket.h>
 #include <asm/socket.h>
 
 struct poll_table_struct;
 struct pipe_inode_info;
 struct inode;
 struct net;
 
-#define NPROTO		34		/* should be enough for now..	*/
+#define NPROTO		AF_MAX
 
 #define SYS_SOCKET	1		/* sys_socket(2)		*/
 #define SYS_BIND	2		/* sys_bind(2)			*/
