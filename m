From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 3/5] sit: ipip6_tunnel_del_prl: return err
Date: Fri, 15 May 2009 14:52:49 +0200
Message-ID: <1242391971-32583-3-git-send-email-contact@saschahlusiak.de>
References: <1242391971-32583-1-git-send-email-contact@saschahlusiak.de>
 <1242391971-32583-2-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:61730 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbZEOMwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 08:52:12 -0400
In-Reply-To: <1242391971-32583-2-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typo. When deleting a PRL entry, return status to userspace
instead of success.
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dc73d6a..9cc9511 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -366,7 +366,7 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 	}
 out:
 	write_unlock(&ipip6_lock);
-	return 0;
+	return err;
 }
 
 static int
-- 
1.6.3

