From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/4] bnx2x: advertise transmit time stamping
Date: Sun, 22 Jul 2012 19:15:39 +0200
Message-ID: <379f084af5dcbcccda309ecb0d0032196fb496f3.1342976654.git.richardcochran__32412.289948161$1342977413$gmane$org@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Willem de Bruijn <willemb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49372 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab2GVRP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 13:15:56 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so3753300wey.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 10:15:55 -0700 (PDT)
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
In-Reply-To: <cover.1342976654.git.richardcochran@gmail.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver now offers software transmit time stamping, so it should
advertise that fact via ethtool. Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bff3129..fc4e0e3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2978,6 +2978,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_module_eeprom	= bnx2x_get_module_eeprom,
 	.get_eee		= bnx2x_get_eee,
 	.set_eee		= bnx2x_set_eee,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5
