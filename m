From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/3] net: mvmdio: adjust multiline comment to net/ style
Date: Mon, 19 Nov 2012 12:00:33 +0100
Message-ID: <1353322834-16952-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35969 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab2KSLBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 06:01:03 -0500
In-Reply-To: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by checkpatch, the multiline comments for net/ and
drivers/net/ have a slightly different format than the one used in the
rest of the kernel, so we adjust our multiline comment accordingly.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 114a0f1..6d6002b 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -42,8 +42,7 @@ struct orion_mdio_dev {
 	void __iomem *smireg;
 };
 
-/*
- * Wait for the SMI unit to be ready for another operation
+/* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(struct mii_bus *bus)
 {
-- 
1.7.9.5
