From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] e1000e: fail when try to setup unsupported features
Date: Mon, 28 Jun 2010 11:26:23 +0200
Message-ID: <20100628112623.492adfcb@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab0F1J0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:26:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/e1000e/ethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 77c5829..6355a1b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -2051,7 +2051,6 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_coalesce		= e1000_get_coalesce,
 	.set_coalesce		= e1000_set_coalesce,
 	.get_flags		= ethtool_op_get_flags,
-	.set_flags		= ethtool_op_set_flags,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
-- 
1.5.5.6
