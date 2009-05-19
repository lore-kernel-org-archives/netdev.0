From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 3/5] sit: ipip6_tunnel_del_prl: return err
Date: Wed, 20 May 2009 00:56:50 +0200
Message-ID: <1242773812-9328-3-git-send-email-contact@saschahlusiak.de>
References: <1242773812-9328-1-git-send-email-contact@saschahlusiak.de>
 <1242773812-9328-2-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:56982 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbZESWzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:55:41 -0400
In-Reply-To: <1242773812-9328-2-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typo. When deleting a PRL entry, return status to userspace
instead of success.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dfedd56..3fd0600 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -368,7 +368,7 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 	}
 out:
 	write_unlock(&ipip6_lock);
-	return 0;
+	return err;
 }
 
 static int
-- 
1.6.3

