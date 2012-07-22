From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/4] e1000: advertise transmit time stamping
Date: Sun, 22 Jul 2012 19:15:40 +0200
Message-ID: <33885adb6b0e97e6b21fd1903fb6ede3ed7b50ab.1342976654.git.richardcochran__14146.7873742387$1342977408$gmane$org@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49372 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160Ab2GVRP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 13:15:58 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so3753300wey.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 10:15:57 -0700 (PDT)
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
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 3103f0b..736a7d9 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1851,6 +1851,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_sset_count         = e1000_get_sset_count,
 	.get_coalesce           = e1000_get_coalesce,
 	.set_coalesce           = e1000_set_coalesce,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5
