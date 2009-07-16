From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 1/8] gianfar: Remove unused DECLARE_MAC_BUF
Date: Thu, 16 Jul 2009 10:51:25 +0200
Message-ID: <1247734285-20648-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: davem@davemloft.net, afleming@freescale.com,
	galak@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:57726 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbZGPIv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 04:51:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is not needed anymore because of the %pM printk conversion specifier.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/gianfar.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4ae1d25..21f5b0a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -304,7 +304,6 @@ static int gfar_probe(struct of_device *ofdev,
 	u32 tempval;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
-	DECLARE_MAC_BUF(mac);
 	int err = 0;
 	int len_devname;
 
-- 
1.6.0.4

