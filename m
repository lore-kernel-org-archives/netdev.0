From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH v2 net-next 3/5] net: Fix non-kernel-doc comments with
 kernel-doc start marker
Date: Tue, 10 Jul 2012 21:55:35 +0100
Message-ID: <1341953735.2605.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41167 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753783Ab2GJUzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 16:55:38 -0400
In-Reply-To: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/ceph/pagelist.c |   14 ++++----------
 net/dcb/dcbnl.c     |    3 +--
 net/ipv4/tcp.c      |    3 +--
 net/tipc/socket.c   |    5 ++---
 4 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 13cb409..665cd23 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -72,8 +72,7 @@ int ceph_pagelist_append(struct ceph_pagelist *pl, const void *buf, size_t len)
 }
 EXPORT_SYMBOL(ceph_pagelist_append);
 
-/**
- * Allocate enough pages for a pagelist to append the given amount
+/* Allocate enough pages for a pagelist to append the given amount
  * of data without without allocating.
  * Returns: 0 on success, -ENOMEM on error.
  */
@@ -95,9 +94,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 }
 EXPORT_SYMBOL(ceph_pagelist_reserve);
 
-/**
- * Free any pages that have been preallocated.
- */
+/* Free any pages that have been preallocated. */
 int ceph_pagelist_free_reserve(struct ceph_pagelist *pl)
 {
 	while (!list_empty(&pl->free_list)) {
@@ -112,9 +109,7 @@ int ceph_pagelist_free_reserve(struct ceph_pagelist *pl)
 }
 EXPORT_SYMBOL(ceph_pagelist_free_reserve);
 
-/**
- * Create a truncation point.
- */
+/* Create a truncation point. */
 void ceph_pagelist_set_cursor(struct ceph_pagelist *pl,
 			      struct ceph_pagelist_cursor *c)
 {
@@ -124,8 +119,7 @@ void ceph_pagelist_set_cursor(struct ceph_pagelist *pl,
 }
 EXPORT_SYMBOL(ceph_pagelist_set_cursor);
 
-/**
- * Truncate a pagelist to the given point. Move extra pages to reserve.
+/* Truncate a pagelist to the given point. Move extra pages to reserve.
  * This won't sleep.
  * Returns: 0 on success,
  *          -EINVAL if the pagelist doesn't match the trunc point pagelist
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 013da86..81f2bb6 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -28,8 +28,7 @@
 #include <linux/module.h>
 #include <net/sock.h>
 
-/**
- * Data Center Bridging (DCB) is a collection of Ethernet enhancements
+/* Data Center Bridging (DCB) is a collection of Ethernet enhancements
  * intended to allow network traffic with differing requirements
  * (highly reliable, no drops vs. best effort vs. low latency) to operate
  * and co-exist on Ethernet.  Current DCB features are:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..a9c08fc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3310,8 +3310,7 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
-/**
- * Each Responder maintains up to two secret values concurrently for
+/* Each Responder maintains up to two secret values concurrently for
  * efficient secret rollover.  Each secret value has 4 states:
  *
  * Generating.  (tcp_secret_generating != tcp_secret_primary)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 11a863d..1ebb49f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1699,9 +1699,8 @@ static int getsockopt(struct socket *sock,
 	return put_user(sizeof(value), ol);
 }
 
-/**
- * Protocol switches for the various types of TIPC sockets
- */
+/* Protocol switches for the various types of TIPC sockets */
+
 static const struct proto_ops msg_ops = {
 	.owner		= THIS_MODULE,
 	.family		= AF_TIPC,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
