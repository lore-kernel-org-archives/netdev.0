From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] xen-netback: fix sparse warning
Date: Wed, 10 Apr 2013 13:54:46 -0700
Message-ID: <20130410135446.3965872e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:54633 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab3DJUzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 16:55:06 -0400
Received: by mail-pb0-f49.google.com with SMTP id um15so465049pbc.8
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 13:55:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning about 0 used as NULL.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/xen-netback/netback.c	2013-04-10 09:10:46.559612835 -0700
+++ b/drivers/net/xen-netback/netback.c	2013-04-10 13:21:51.408176509 -0700
@@ -1551,7 +1551,7 @@ static void xen_netbk_idx_release(struct
 
 	xenvif_put(vif);
 
-	netbk->mmap_pages[pending_idx]->mapping = 0;
+	netbk->mmap_pages[pending_idx]->mapping = NULL;
 	put_page(netbk->mmap_pages[pending_idx]);
 	netbk->mmap_pages[pending_idx] = NULL;
 }
