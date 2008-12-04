From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] net: remove duplicated #include
Date: Thu, 4 Dec 2008 10:26:50 +0800
Message-ID: <20081204022650.GA5159@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:56277 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbYLDC0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 21:26:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: remove duplicated #include

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 92764d8..e9d65ea 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -69,7 +69,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mutex.h>
-#include <linux/thread_info.h>
 #include <linux/wanrouter.h>
 #include <linux/if_bridge.h>
 #include <linux/if_frad.h>
-- 
1.5.6.3

-- 
Jianjun Kong | Happy Hacking
HOMEPAGE: http://kongove.cn/
GTALK: kongjianjun@gmail.com
