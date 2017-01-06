From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: add CALIPSO to the list of built-in protocols
Date: Fri, 06 Jan 2017 14:26:54 -0500
Message-ID: <148373081425.18818.6670627192248645738.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965836AbdAFT0z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 14:26:55 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 465E53B709
        for <netdev@vger.kernel.org>; Fri,  6 Jan 2017 19:26:56 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

When we added CALIPSO support in Linux v4.8 we forgot to add it to the
list of supported protocols with display at boot.

Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_kapi.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 28c56b95fb7f..ea7c67050792 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1502,10 +1502,7 @@ static int __init netlbl_init(void)
 	printk(KERN_INFO "NetLabel: Initializing\n");
 	printk(KERN_INFO "NetLabel:  domain hash size = %u\n",
 	       (1 << NETLBL_DOMHSH_BITSIZE));
-	printk(KERN_INFO "NetLabel:  protocols ="
-	       " UNLABELED"
-	       " CIPSOv4"
-	       "\n");
+	printk(KERN_INFO "NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO\n");
 
 	ret_val = netlbl_domhsh_init(NETLBL_DOMHSH_BITSIZE);
 	if (ret_val != 0)
