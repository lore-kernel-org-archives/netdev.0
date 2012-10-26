From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 79/82] net/core/sock.c:1267:3: error: too
 many arguments to function 'sock_update_classid'
Date: Fri, 26 Oct 2012 05:07:20 -0400 (EDT)
Message-ID: <20121026.050720.367513259148701730.davem@davemloft.net>
References: <508a42d2./QGsZgSRCzpLxMff%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.wagner@bmw-carit.de, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757792Ab2JZJHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 05:07:24 -0400
In-Reply-To: <508a42d2./QGsZgSRCzpLxMff%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fixed thusly:

[PATCH] net: Update args to dummy sock_update_classid().

Only the real implementation got updated.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/cls_cgroup.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 571de6e..2581638 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -61,7 +61,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else /* !CGROUP_NET_CLS_CGROUP */
-static inline void sock_update_classid(struct sock *sk)
+static inline void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
 }
 
-- 
1.7.11.7
