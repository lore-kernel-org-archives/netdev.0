From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Export bpf_prog_create_from_user().
Date: Mon, 17 Aug 2015 14:38:15 -0700 (PDT)
Message-ID: <20150817.143815.395724920116560240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbbHQViQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:38:16 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id F24FF58635B
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:38:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/filter.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index a50dbfa..f818422 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1124,6 +1124,7 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 	*pfp = fp;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(bpf_prog_create_from_user);
 
 void bpf_prog_destroy(struct bpf_prog *fp)
 {
-- 
2.1.0
