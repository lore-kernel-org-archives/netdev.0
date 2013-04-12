From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] lsm: export the security_skb_owned_by() function
Date: Fri, 12 Apr 2013 11:43:00 -0400
Message-ID: <20130412154300.26512.67761.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755118Ab3DLPnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 11:43:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another bit we missed when adding the skb_owned_by() hook.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 security/security.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/security.c b/security/security.c
index 03f248b..9eebd6b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1294,7 +1294,7 @@ void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 	security_ops->skb_owned_by(skb, sk);
 }
-
+EXPORT_SYMBOL(security_skb_owned_by);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
