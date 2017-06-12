From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v3 3/9] net: mvmdio: use GENMASK for masks
Date: Mon, 12 Jun 2017 11:57:39 +0200
Message-ID: <20170612095745.11300-4-antoine.tenart@free-electrons.com>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:43204 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdFLKAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:00:14 -0400
In-Reply-To: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic patch to use the GENMASK helper for masks.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 17b518b13ae3..583f1c5753c2 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -138,7 +138,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 		goto out;
 	}
 
-	ret = val & 0xFFFF;
+	ret = val & GENMASK(15, 0);
 out:
 	mutex_unlock(&dev->lock);
 	return ret;
-- 
2.9.4
