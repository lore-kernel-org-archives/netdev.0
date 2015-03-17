From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 16/16 linux-next] via-velocity: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:28 +0100
Message-ID: <1426617628-937-7-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:47678 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932614AbbCQSkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:40:46 -0400
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/via/via-velocity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index c20206f..ae68afd 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -392,7 +392,7 @@ MODULE_DEVICE_TABLE(pci, velocity_pci_id_table);
  *	Describe the OF device identifiers that we support in this
  *	device driver. Used for devicetree nodes.
  */
-static struct of_device_id velocity_of_ids[] = {
+static const struct of_device_id velocity_of_ids[] = {
 	{ .compatible = "via,velocity-vt6110", .data = &chip_info_table[0] },
 	{ /* Sentinel */ },
 };
-- 
2.1.0
