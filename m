From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 1/1] xfrm: clone mark when cloning policy
Date: Tue, 23 Feb 2010 18:08:04 -0500
Message-ID: <1266966484-1750-1-git-send-email-hadi@cyberus.ca>
References: <sk-mark-clone>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:64821 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab0BWXIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 18:08:14 -0500
Received: by pwj8 with SMTP id 8so4287863pwj.19
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 15:08:14 -0800 (PST)
In-Reply-To: <sk-mark-clone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

When we clone the SP, we should also clone the mark.
Useful for socket based SPs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_policy.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2a6e646..34a5ef8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1154,6 +1154,7 @@ static struct xfrm_policy *clone_policy(struct xfrm_policy *old, int dir)
 		}
 		newp->lft = old->lft;
 		newp->curlft = old->curlft;
+		newp->mark = old->mark;
 		newp->action = old->action;
 		newp->flags = old->flags;
 		newp->xfrm_nr = old->xfrm_nr;
-- 
1.6.0.4

