From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 06/16 linux-next] net: ethernet: apple: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:37 +0100
Message-ID: <1426617469-781-7-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:46771 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753002AbbCQSiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:38:11 -0400
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/apple/bmac.c | 2 +-
 drivers/net/ethernet/apple/mace.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index daae0e0..2f98846 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1621,7 +1621,7 @@ static int bmac_remove(struct macio_dev *mdev)
 	return 0;
 }
 
-static struct of_device_id bmac_match[] =
+static const struct of_device_id bmac_match[] =
 {
 	{
 	.name 		= "bmac",
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 7fcaf0d..a1894828 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -984,7 +984,7 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
     return IRQ_HANDLED;
 }
 
-static struct of_device_id mace_match[] =
+static const struct of_device_id mace_match[] =
 {
 	{
 	.name 		= "mace",
-- 
2.1.0
