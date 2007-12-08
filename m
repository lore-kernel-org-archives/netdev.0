From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 2/3] [TFRC]: The function tfrc_rx_hist_entry_delete() is not used anymore
Date: Sat,  8 Dec 2007 16:52:12 -0200
Message-ID: <1197139933-11609-3-git-send-email-acme@redhat.com>
References: <1197139933-11609-1-git-send-email-acme@redhat.com>
 <1197139933-11609-2-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:3633 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbXLHSwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 13:52:47 -0500
Received: by an-out-0708.google.com with SMTP id d31so284712and
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2007 10:52:46 -0800 (PST)
In-Reply-To: <1197139933-11609-2-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/packet_history.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 54cd23e..af44082 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -151,11 +151,6 @@ void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-static inline void tfrc_rx_hist_entry_delete(struct tfrc_rx_hist_entry *entry)
-{
-	kmem_cache_free(tfrc_rx_hist_slab, entry);
-}
-
 /**
  * tfrc_rx_hist_entry - return the n-th history entry after loss_start
  */
-- 
1.5.3.4

