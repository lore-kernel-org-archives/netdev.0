From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport inet_listen_wlock
Date: Wed, 13 Feb 2008 23:29:48 +0200
Message-ID: <20080213212948.GL3383@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:50762 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763025AbYBMVaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 16:30:03 -0500
Received: from cs181133002.pp.htv.fi (cs181133002.pp.htv.fi [82.181.133.2])
	by smtp4.pp.htv.fi (Postfix) with ESMTP id D688F5BC00D
	for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 23:30:02 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no linger used EXPORT_SYMBOL(inet_listen_wlock).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
08c580a0a3219ce72f5c534c8868e75c4c224e01 diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index e6a0072..1aba606 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -120,8 +120,6 @@ void inet_listen_wlock(struct inet_hashinfo *hashinfo)
 	}
 }
 
-EXPORT_SYMBOL(inet_listen_wlock);
-
 /*
  * Don't inline this cruft. Here are some nice properties to exploit here. The
  * BSD API does not allow a listening sock to specify the remote port nor the

