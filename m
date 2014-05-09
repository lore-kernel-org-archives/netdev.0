From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: include rx-compl error counter in ethtool stats
Date: Fri, 9 May 2014 13:29:18 +0530
Message-ID: <1399622359-25926-7-git-send-email-sathya.perla@emulex.com>
References: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:21313 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbaEIH4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:56:22 -0400
In-Reply-To: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index cffbb13..970ae33 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -132,6 +132,7 @@ static const struct be_ethtool_stat et_rx_stats[] = {
 	{DRVSTAT_RX_INFO(rx_bytes)},/* If moving this member see above note */
 	{DRVSTAT_RX_INFO(rx_pkts)}, /* If moving this member see above note */
 	{DRVSTAT_RX_INFO(rx_compl)},
+	{DRVSTAT_RX_INFO(rx_compl_err)},
 	{DRVSTAT_RX_INFO(rx_mcast_pkts)},
 	/* Number of page allocation failures while posting receive buffers
 	 * to HW.
-- 
1.7.1
