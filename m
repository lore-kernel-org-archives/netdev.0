From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] net: Update kernel-doc for
 netif_set_real_num_rx_queues()
Date: Thu, 07 Oct 2010 14:08:11 +0100
Message-ID: <1286456891.2271.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	therbert@google.com, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953Ab0JGNIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 09:08:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synchronise the comment with the preceding implementation change.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f78d996..599a1fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1575,8 +1575,8 @@ EXPORT_SYMBOL(netif_set_real_num_tx_queues);
  *
  *	This must be called either with the rtnl_lock held or before
  *	registration of the net device.  Returns 0 on success, or a
- *	negative error code.  If called before registration, it also
- *	sets the maximum number of queues, and always succeeds.
+ *	negative error code.  If called before registration, it always
+ *	succeeds.
  */
 int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 {
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

