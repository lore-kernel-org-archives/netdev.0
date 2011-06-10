From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/1] IPVS remove unused var from migration to netns
Date: Fri, 10 Jun 2011 10:19:09 +0200
Message-ID: <1307693949-22301-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: <horms@verge.net.au>, <ja@ssi.bg>, <wensong@linux-vs.org>,
	<lvs-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove variable ctl_key from struct netns_ipvs,
it's a leftover from early netns work.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 481f856..34a6fa8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -836,8 +836,6 @@ struct netns_ipvs {
 	int			num_services;    /* no of virtual services */
 
 	rwlock_t		rs_lock;         /* real services table */
-	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
-	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
 	/* Trash for destinations */
 	struct list_head	dest_trash;
 	/* Service counters */
-- 
1.6.0.2

