From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 1/6] xfrm: remove unused function
Date: Mon,  9 Jan 2017 14:20:45 +0100
Message-ID: <1483968050-788-2-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48764 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761424AbdAINUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:35 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has been ifdef'd out for more than 10 years, remove it.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/xfrm4_state.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 542074c00c78..d6660a8c0ea5 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -90,11 +90,3 @@ void __init xfrm4_state_init(void)
 {
 	xfrm_state_register_afinfo(&xfrm4_state_afinfo);
 }
-
-#if 0
-void __exit xfrm4_state_fini(void)
-{
-	xfrm_state_unregister_afinfo(&xfrm4_state_afinfo);
-}
-#endif  /*  0  */
-
-- 
2.7.3
