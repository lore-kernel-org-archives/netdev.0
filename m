From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/4] hv_netvsc: Clean up unused parameter from netvsc_get_rss_hash_opts()
Date: Mon, 21 Aug 2017 19:22:38 -0700
Message-ID: <1503368560-14331-3-git-send-email-haiyangz@exchange.microsoft.com>
References: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The parameter "nvdev" is not in use.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4677d21..d8612b1 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1228,8 +1228,7 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 }
 
 static int
-netvsc_get_rss_hash_opts(struct netvsc_device *nvdev,
-			 struct ethtool_rxnfc *info)
+netvsc_get_rss_hash_opts(struct ethtool_rxnfc *info)
 {
 	info->data = RXH_IP_SRC | RXH_IP_DST;
 
@@ -1267,7 +1266,7 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 		return 0;
 
 	case ETHTOOL_GRXFH:
-		return netvsc_get_rss_hash_opts(nvdev, info);
+		return netvsc_get_rss_hash_opts(info);
 	}
 	return -EOPNOTSUPP;
 }
-- 
1.7.1
