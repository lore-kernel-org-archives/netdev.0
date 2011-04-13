From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH] net: can: mscan: fix build breakage in mpc5xxx_can
Date: Wed, 13 Apr 2011 11:49:28 +0200
Message-ID: <1302688168-26862-1-git-send-email-agust@denx.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:50809 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108Ab1DMJtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 05:49:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 74888760d40b3ac9054f9c5fa07b566c0676ba2d
"dt/net: Eliminate users of of_platform_{,un}register_driver"
broke building mscan driver. Fix it.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
Cc: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index c0a1bc5..bd1d811 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -260,7 +260,7 @@ static int __devinit mpc5xxx_can_probe(struct platform_device *ofdev)
 
 	if (!ofdev->dev.of_match)
 		return -EINVAL;
-	data = (struct mpc5xxx_can_data *)of_dev->dev.of_match->data;
+	data = (struct mpc5xxx_can_data *)ofdev->dev.of_match->data;
 
 	base = of_iomap(np, 0);
 	if (!base) {
-- 
1.7.1

