From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] net: fix eth.c kernel-doc warning
Date: Mon, 25 Jul 2011 11:41:01 -0700
Message-ID: <20110725114101.04e84376.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy1-pub.bluehost.com ([66.147.249.253]:55357 "HELO
	oproxy1-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751350Ab1GYSlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 14:41:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix new kernel-doc warning in eth.c:

Warning(net/ethernet/eth.c:237): No description found for parameter 'type'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/ethernet/eth.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.0-git4.orig/net/ethernet/eth.c
+++ linux-3.0-git4/net/ethernet/eth.c
@@ -231,6 +231,7 @@ EXPORT_SYMBOL(eth_header_parse);
  * eth_header_cache - fill cache entry from neighbour
  * @neigh: source neighbour
  * @hh: destination cache entry
+ * @type: Ethernet type field
  * Create an Ethernet header template from the neighbour.
  */
 int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type)
