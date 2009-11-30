From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 02/20] net: Implement for_each_netdev_reverse.
Date: Mon, 30 Nov 2009 00:25:26 -0800
Message-ID: <1259569530-30609-1-git-send-email-ebiederm@xmission.com>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53806 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbZK3IZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 03:25:32 -0500
In-Reply-To: <m1ljhodbtw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

I will need this shortly to implement network namespace shutdown
batching.  For sanity sake network devices should be removed in
the reverse order they were created in.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netdevice.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9428793..daf13d3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1112,6 +1112,8 @@ extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
+#define for_each_netdev_reverse(net, d)	\
+		list_for_each_entry_reverse(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_rcu(net, d)		\
 		list_for_each_entry_rcu(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_safe(net, d, n)	\
-- 
1.6.5.2.143.g8cc62

