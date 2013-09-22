From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/12] psnap.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:18 -0700
Message-ID: <90994e6e96300c1594ad5de59dae90c4f20e314c.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0157.hostedemail.com ([216.40.44.157]:52663 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752446Ab3IVRcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 13:32:33 -0400
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/psnap.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/psnap.h b/include/net/psnap.h
index fe456c2..78db4cc 100644
--- a/include/net/psnap.h
+++ b/include/net/psnap.h
@@ -1,11 +1,11 @@
 #ifndef _NET_PSNAP_H
 #define _NET_PSNAP_H
 
-extern struct datalink_proto *
+struct datalink_proto *
 register_snap_client(const unsigned char *desc,
 		     int (*rcvfunc)(struct sk_buff *, struct net_device *,
 				    struct packet_type *,
 				    struct net_device *orig_dev));
-extern void unregister_snap_client(struct datalink_proto *proto);
+void unregister_snap_client(struct datalink_proto *proto);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
