From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] dcbnl: Use BUG_ON() instead of BUG()
Date: Thu, 14 Jun 2012 04:40:15 -0400
Message-ID: <20120614084015.GC29738@canuck.infradead.org>
References: <cover.1339591572.git.tgraf@suug.ch>
 <20120613.155541.26513304496438357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39844 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab2FNIkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:40:17 -0400
Content-Disposition: inline
In-Reply-To: <20120613.155541.26513304496438357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index da6ee81..0a36007 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -208,10 +208,7 @@ static struct sk_buff *dcbnl_newmsg(int type, u8 cmd, u32 port, u32 seq,
 		return NULL;
 
 	nlh = nlmsg_put(skb, port, seq, type, sizeof(*dcb), flags);
-	if (!nlh) {
-		/* header should always fit, allocation must be buggy */
-		BUG();
-	}
+	BUG_ON(!nlh);
 
 	dcb = nlmsg_data(nlh);
 	dcb->dcb_family = AF_UNSPEC;
