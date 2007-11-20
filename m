From: Joe Perches <joe@perches.com>
Subject: [PATCH 51/59] net/dccp: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:38 -0800
Message-ID: <1195523627-15389-9-git-send-email-joe@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Networking Team <netdev@vger.kernel.org>, dccp@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2209 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756331AbXKTBxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:53:54 -0500
In-Reply-To: <1195523627-15389-8-git-send-email-joe@perches.com>
Message-Id: <29542305a25cef11c0f5f7e978d9bf50ef60b4b3.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dccp/ccids/lib/loss_interval.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 40ad428..d26b88d 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -166,7 +166,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 	}
 
 	if (unlikely(interval == 0)) {
-		DCCP_WARN("%s(%p), Could not find a win_count interval > 0."
+		DCCP_WARN("%s(%p), Could not find a win_count interval > 0. "
 			  "Defaulting to 1\n", dccp_role(sk), sk);
 		interval = 1;
 	}
-- 
1.5.3.5.652.gf192c

