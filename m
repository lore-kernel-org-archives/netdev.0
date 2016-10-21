From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/13] netfilter: conntrack: remove obsolete sysctl (nf_conntrack_events_retry_timeout)
Date: Fri, 21 Oct 2016 12:12:13 +0200
Message-ID: <1477044743-18948-4-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This entry has been removed in commit 9500507c6138.

Fixes: 9500507c6138 ("netfilter: conntrack: remove timer from ecache extension")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
2.1.4

