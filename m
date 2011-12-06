From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH] netback: fix typo in comment
Date: Tue, 6 Dec 2011 12:04:50 +0000
Message-ID: <1323173090-7867-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, Wei Liu <wei.liu2@citrix.com>
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:14838 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933238Ab1LFMEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 07:04:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"variables a used" should be "variables are used".

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3ecb5aa..639cf8a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -395,7 +395,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	struct gnttab_copy *copy_gop;
 	struct netbk_rx_meta *meta;
 	/*
-	 * These variables a used iff get_page_ext returns true,
+	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
 	 */
 	unsigned int uninitialized_var(group), uninitialized_var(idx);
-- 
1.7.2.5
