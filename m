From: Robert Richter <rrichter@caviumnetworks.com>
Subject: [PATCH 1/2] net: thunderx: Fix const type in nicvf_set_rxfh()
Date: Thu, 18 Feb 2016 13:39:08 +0100
Message-ID: <1455799149-19590-2-git-send-email-rrichter@caviumnetworks.com>
References: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rrichter@cavium.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S . Miller" <davem@davemloft.net>, Sunil Goutham
 <sgoutham@cavium.com>, Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

>From struct ethtool_ops:

        int     (*set_rxfh)(struct net_device *, const u32 *indir,
                            const u8 *key, const u8 hfunc);

Change function arg of hfunc to const type.

Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index a12b2e38cf61..fb79529ac8c7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -581,7 +581,7 @@ static int nicvf_get_rxfh(struct net_device *dev, u32 *indir, u8 *hkey,
 }
 
 static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
-			  const u8 *hkey, u8 hfunc)
+			const u8 *hkey, const u8 hfunc)
 {
 	struct nicvf *nic = netdev_priv(dev);
 	struct nicvf_rss_info *rss = &nic->rss_info;
-- 
2.7.0.rc3
