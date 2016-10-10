From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/2] conntrack: remove obsolete sysctl (nf_conntrack_events_retry_timeout)
Date: Mon, 10 Oct 2016 12:18:23 +0200
Message-ID: <1476094704-17452-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fw@strlen.de, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38671 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbcJJKS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 06:18:58 -0400
In-Reply-To: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This entry has been removed in commit 9500507c6138.

Fixes: 9500507c6138 ("netfilter: conntrack: remove timer from ecache extension")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/networking/nf_conntrack-sysctl.txt | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index 4fb51d32fccc..399e4e866a9c 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -33,24 +33,6 @@ nf_conntrack_events - BOOLEAN
 	If this option is enabled, the connection tracking code will
 	provide userspace with connection tracking events via ctnetlink.
 
-nf_conntrack_events_retry_timeout - INTEGER (seconds)
-	default 15
-
-	This option is only relevant when "reliable connection tracking
-	events" are used.  Normally, ctnetlink is "lossy", that is,
-	events are normally dropped when userspace listeners can't keep up.
-
-	Userspace can request "reliable event mode".  When this mode is
-	active, the conntrack will only be destroyed after the event was
-	delivered.  If event delivery fails, the kernel periodically
-	re-tries to send the event to userspace.
-
-	This is the maximum interval the kernel should use when re-trying
-	to deliver the destroy event.
-
-	A higher number means there will be fewer delivery retries and it
-	will take longer for a backlog to be processed.
-
 nf_conntrack_expect_max - INTEGER
 	Maximum size of expectation table.  Default value is
 	nf_conntrack_buckets / 256. Minimum is 1.
-- 
2.8.1
