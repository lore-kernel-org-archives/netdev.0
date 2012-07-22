From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 4/4] forcedeth: advertise transmit time stamping
Date: Sun, 22 Jul 2012 19:15:42 +0200
Message-ID: <d95c3b5bf30e3a7d056ad7f9fb774bbf572dc217.1342976654.git.richardcochran__41309.207204222$1342977408$gmane$org@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:58261 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab2GVRQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 13:16:02 -0400
Received: by wibhm11 with SMTP id hm11so2141164wib.1
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 10:16:01 -0700 (PDT)
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver now offers software transmit time stamping, so it should
advertise that fact via ethtool. Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Cc: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 67edc2e..f45def0 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5182,6 +5182,7 @@ static const struct ethtool_ops ops = {
 	.get_ethtool_stats = nv_get_ethtool_stats,
 	.get_sset_count = nv_get_sset_count,
 	.self_test = nv_self_test,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 /* The mgmt unit and driver use a semaphore to access the phy during init */
-- 
1.7.2.5
