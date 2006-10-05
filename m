From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] kernel-doc fix for sock.h
Date: Thu, 5 Oct 2006 09:34:30 -0700
Message-ID: <20061005093430.4dc842c5.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:44689 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750743AbWJEQdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 12:33:07 -0400
Received: from midway.site ([71.117.236.95]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 5 Oct 2006 09:33:01 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warning in include/net/sock.h:
Warning(/var/linsrc/linux-2619-rc1-pv//include/net/sock.h:894): No description found for parameter 'rcu'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/net/sock.h |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

--- linux-2619-rc1-pv.orig/include/net/sock.h
+++ linux-2619-rc1-pv/include/net/sock.h
@@ -884,8 +884,7 @@ static inline int sk_filter(struct sock 
 
 /**
  *	sk_filter_release: Release a socket filter
- *	@sk: socket
- *	@fp: filter to remove
+ *	@rcu: rcu_head that contains the sk_filter info to remove
  *
  *	Remove a filter from a socket and release its resources.
  */


---
