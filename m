From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 03/12] be2net: add a description for counter rx_input_fifo_overflow_drop
Date: Mon, 1 Sep 2014 11:54:15 +0530
Message-ID: <1409552664-15990-4-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19158 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbaIAGVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:54 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 0cd3311..d8d7a4a 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -78,6 +78,11 @@ static const struct be_ethtool_stat et_stats[] = {
 	 * fifo must never overflow.
 	 */
 	{DRVSTAT_INFO(rxpp_fifo_overflow_drop)},
+	/* Received packets dropped when the RX block runs out of space in
+	 * one of its input FIFOs. This could happen due a long burst of
+	 * minimum-sized (64b) frames in the receive path.
+	 * This counter may also be erroneously incremented rarely.
+	 */
 	{DRVSTAT_INFO(rx_input_fifo_overflow_drop)},
 	{DRVSTAT_INFO(rx_ip_checksum_errs)},
 	{DRVSTAT_INFO(rx_tcp_checksum_errs)},
-- 
1.7.1
