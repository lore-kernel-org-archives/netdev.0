From: Joe Perches <joe@perches.com>
Subject: [PATCH 54/59] net/irda: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:41 -0800
Message-ID: <1195523627-15389-12-git-send-email-joe@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
 <1195523627-15389-9-git-send-email-joe@perches.com>
 <1195523627-15389-10-git-send-email-joe@perches.com>
 <1195523627-15389-11-git-send-email-joe@perches.com>
Cc: Networking Team <netdev@vger.kernel.org>,
	Samuel Ortiz <samuel@sortiz.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2214 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758761AbXKTBx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:53:58 -0500
In-Reply-To: <1195523627-15389-11-git-send-email-joe@perches.com>
Message-Id: <40f9ed858135b417a27a0a628667cc0da0d91e73.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/irda/iriap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index dc5e34a..a86a5d8 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -928,7 +928,7 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 
 	opcode = fp[0];
 	if (~opcode & 0x80) {
-		IRDA_WARNING("%s: IrIAS multiframe commands or results"
+		IRDA_WARNING("%s: IrIAS multiframe commands or results "
 			     "is not implemented yet!\n", __FUNCTION__);
 		return;
 	}
-- 
1.5.3.5.652.gf192c

