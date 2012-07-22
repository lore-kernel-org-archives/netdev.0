From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/4] e1000e: advertise transmit time stamping
Date: Sun, 22 Jul 2012 19:15:41 +0200
Message-ID: <e0e31f0229b5bfda1684122498b4d6fb3195cf26.1342976654.git.richardcochran__2390.25659761882$1342977408$gmane$org@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59250 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab2GVRQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 13:16:00 -0400
Received: by wgbdr13 with SMTP id dr13so5119554wgb.1
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 10:15:59 -0700 (PDT)
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver now offers software transmit time stamping, so it should
advertise that fact via ethtool. Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Cc: Willem de Bruijn <willemb@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: e1000-devel@lists.sourceforge.net
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 105d554..0349e24 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -2061,6 +2061,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_coalesce		= e1000_get_coalesce,
 	.set_coalesce		= e1000_set_coalesce,
 	.get_rxnfc		= e1000_get_rxnfc,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5
