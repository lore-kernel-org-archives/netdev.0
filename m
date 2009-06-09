From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/8] qlge: Add set TX csum ethtool op.
Date: Tue,  9 Jun 2009 08:39:31 -0700
Message-ID: <1244561974-25662-5-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbZFIPrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:16 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index ea02163..37c99fe 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -404,6 +404,7 @@ const struct ethtool_ops qlge_ethtool_ops = {
 	.get_rx_csum = ql_get_rx_csum,
 	.set_rx_csum = ql_set_rx_csum,
 	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_csum,
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
-- 
1.6.0.2

