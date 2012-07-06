From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/5] net: Fix non-kernel-doc comments with
 kernel-doc start marker
Date: Fri, 6 Jul 2012 23:45:42 +0100
Message-ID: <1341614742.2923.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30736 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757049Ab2GFWpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:45:45 -0400
In-Reply-To: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/ceph/pagelist.c |    6 +++---
 net/dcb/dcbnl.c     |    2 +-
 net/ipv4/tcp.c      |    2 +-
 net/tipc/socket.c   |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 13cb409..693852f 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -95,7 +95,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 }
 EXPORT_SYMBOL(ceph_pagelist_reserve);
 
-/**
+/*
  * Free any pages that have been preallocated.
  */
 int ceph_pagelist_free_reserve(struct ceph_pagelist *pl)
@@ -112,7 +112,7 @@ int ceph_pagelist_free_reserve(struct ceph_pagelist *pl)
 }
 EXPORT_SYMBOL(ceph_pagelist_free_reserve);
 
-/**
+/*
  * Create a truncation point.
  */
 void ceph_pagelist_set_cursor(struct ceph_pagelist *pl,
@@ -124,7 +124,7 @@ void ceph_pagelist_set_cursor(struct ceph_pagelist *pl,
 }
 EXPORT_SYMBOL(ceph_pagelist_set_cursor);
 
-/**
+/*
  * Truncate a pagelist to the given point. Move extra pages to reserve.
  * This won't sleep.
  * Returns: 0 on success,
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 013da86..ed84d19 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -28,7 +28,7 @@
 #include <linux/module.h>
 #include <net/sock.h>
 
-/**
+/*
  * Data Center Bridging (DCB) is a collection of Ethernet enhancements
  * intended to allow network traffic with differing requirements
  * (highly reliable, no drops vs. best effort vs. low latency) to operate
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..c7a22d3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3310,7 +3310,7 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
-/**
+/*
  * Each Responder maintains up to two secret values concurrently for
  * efficient secret rollover.  Each secret value has 4 states:
  *
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 11a863d..1367270 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1699,7 +1699,7 @@ static int getsockopt(struct socket *sock,
 	return put_user(sizeof(value), ol);
 }
 
-/**
+/*
  * Protocol switches for the various types of TIPC sockets
  */
 static const struct proto_ops msg_ops = {
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
