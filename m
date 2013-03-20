From: tingwei liu <tingw.liu@gmail.com>
Subject: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Wed, 20 Mar 2013 17:33:40 +0800
Message-ID: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50674 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab3CTJdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 05:33:41 -0400
Received: by mail-ie0-f172.google.com with SMTP id c10so1838755ieb.3
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 02:33:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 5d787e8c3725efa6af3036eeb52aba1905c70de9 Mon Sep 17 00:00:00 2001
From: root <root@linux-19.site>
Date: Wed, 20 Mar 2013 17:39:59 +0800
Subject: [PATCH] Change a wrong explain about dev_get_by_name


Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
---
 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d540ced..20c5c7c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -700,10 +700,10 @@ EXPORT_SYMBOL(dev_get_by_name_rcu);
  *     @name: name to find
  *
  *     Find an interface by name. This can be called from any
- *     context and does its own locking. The returned handle has
- *     the usage count incremented and the caller must use dev_put() to
- *     release it when it is no longer needed. %NULL is returned if no
- *     matching device is found.
+ *     context except hard irq context and does its own locking.
+ *     The returned handle has the usage count incremented and the
+ *     caller must use dev_put() to release it when it is no longer
+ *     needed. %NULL is returned if no matching device is found.
  */

 struct net_device *dev_get_by_name(struct net *net, const char *name)
--
1.6.0.2
