From: Jan Engelhardt <jengelh@medozas.de>
Subject: [patch] netns: let net_generic take pointer-to-const args
Date: Sun, 21 Nov 2010 05:07:21 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:38318 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab0KUEHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 23:07:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent 2801f1c311f8388ea80d78555747d449b46ea90d (v2.6.37-rc1-225-g2801f1c)
commit 381a4560f0062f5c1919f8199772d7af7281349e
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Nov 21 04:35:16 2010 +0100

netns: let net_generic take pointer-to-const args

This commit is same in nature as v2.6.37-rc1-755-g3654654; the network
namespace itself is not modified when calling net_generic, so the
parameter can be const.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/net/netns/generic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
index 81a31c0..3419bf5 100644
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -30,7 +30,7 @@ struct net_generic {
 	void *ptr[0];
 };
 
-static inline void *net_generic(struct net *net, int id)
+static inline void *net_generic(const struct net *net, int id)
 {
 	struct net_generic *ng;
 	void *ptr;
-- 
# Created with git-export-patch

