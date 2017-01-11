From: Robert Richter <rrichter@cavium.com>
Subject: [PATCH net-next v2] net: thunderx: Make hfunc variable const type in nicvf_set_rxfh()
Date: Wed, 11 Jan 2017 18:04:32 +0100
Message-ID: <20170111170432.31210-1-rrichter@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>, <netdev@vger.kernel.org>,
        Robert Richter <rrichter@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0060.outbound.protection.outlook.com ([104.47.37.60]:34129
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759042AbdAKRFB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 12:05:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From struct ethtool_ops:

        int     (*set_rxfh)(struct net_device *, const u32 *indir,
                            const u8 *key, const u8 hfunc);

Change function arg of hfunc to const type.

V2: Fixed indentation.

Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index 2e74bbaa38e1..5ac474683c98 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -635,7 +635,7 @@ static int nicvf_get_rxfh(struct net_device *dev, u32 *indir, u8 *hkey,
 }
 
 static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
-			  const u8 *hkey, u8 hfunc)
+			  const u8 *hkey, const u8 hfunc)
 {
 	struct nicvf *nic = netdev_priv(dev);
 	struct nicvf_rss_info *rss = &nic->rss_info;
-- 
2.11.0
