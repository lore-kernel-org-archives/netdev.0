From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/2] net: correct lock name in dev_[uc/mc]_sync documentations.
Date: Mon,  9 Jan 2012 17:18:34 +0100
Message-ID: <1326125915-2711-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932170Ab2AIQSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 11:18:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/dev_addr_lists.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index febba51..c34ce9f 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -427,7 +427,7 @@ EXPORT_SYMBOL(dev_uc_del);
  *
  *	Add newly added addresses to the destination device and release
  *	addresses that have no users left. The source device must be
- *	locked by netif_tx_lock_bh.
+ *	locked by netif_addr_lock_bh.
  *
  *	This function is intended to be called from the dev->set_rx_mode
  *	function of layered software devices.
@@ -590,7 +590,7 @@ EXPORT_SYMBOL(dev_mc_del_global);
  *
  *	Add newly added addresses to the destination device and release
  *	addresses that have no users left. The source device must be
- *	locked by netif_tx_lock_bh.
+ *	locked by netif_addr_lock_bh.
  *
  *	This function is intended to be called from the ndo_set_rx_mode
  *	function of layered software devices.
-- 
1.7.6
