From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 3/9] net: mvmdio: use GENMASK for masks
Date: Wed,  7 Jun 2017 10:38:04 +0200
Message-ID: <20170607083810.30922-4-antoine.tenart@free-electrons.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37597 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdFGIjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 04:39:14 -0400
In-Reply-To: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic patch to use the GENMASK helper for masks.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 17b518b13ae3..96af8d57d9e5 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -138,7 +138,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 		goto out;
 	}
 
-	ret = val & 0xFFFF;
+	ret = val & GENMASK(15,0);
 out:
 	mutex_unlock(&dev->lock);
 	return ret;
-- 
2.9.4
