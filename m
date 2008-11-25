From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ah4/ah6: remove useless NULL assignments
Date: Tue, 25 Nov 2008 06:35:22 +0300
Message-ID: <20081125033522.GA2617@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:32010 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYKYDbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 22:31:41 -0500
Received: by ug-out-1314.google.com with SMTP id 39so950987ugf.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 19:31:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct will be kfreed in a moment, so...

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ah4.c |    2 --
 net/ipv6/ah6.c |    2 --
 2 files changed, 4 deletions(-)

--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -293,9 +293,7 @@ static void ah_destroy(struct xfrm_state *x)
 		return;
 
 	kfree(ahp->work_icv);
-	ahp->work_icv = NULL;
 	crypto_free_hash(ahp->tfm);
-	ahp->tfm = NULL;
 	kfree(ahp);
 }
 
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -509,9 +509,7 @@ static void ah6_destroy(struct xfrm_state *x)
 		return;
 
 	kfree(ahp->work_icv);
-	ahp->work_icv = NULL;
 	crypto_free_hash(ahp->tfm);
-	ahp->tfm = NULL;
 	kfree(ahp);
 }
 
