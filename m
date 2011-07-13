From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH 1/4] slip: remove redundant NULL-pointer check before calling slhc_free
Date: Wed, 13 Jul 2011 11:45:37 +0400
Message-ID: <CAKh5naafU9=0dZr+QiXjbn57hzCM9BN3YA8h0FpJD6dMH+g4hA@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: matvejchikov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:62118 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965002Ab1GMHp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 03:45:58 -0400
Received: by qyk9 with SMTP id 9so3247939qyk.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 00:45:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 8ec1a9a..e8c4582 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -194,8 +194,7 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
 err_exit:
 #ifdef SL_INCLUDE_CSLIP
 	kfree(cbuff);
-	if (slcomp)
-		slhc_free(slcomp);
+	slhc_free(slcomp);
 #endif
 	kfree(xbuff);
 	kfree(rbuff);
-- 
1.7.6
