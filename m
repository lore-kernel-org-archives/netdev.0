From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 25/28] stmmac: Support the
	get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:49 +0200
Message-ID: <e8f2b42fb0c2c03b4b39361e222e84baa9740d54.1333474525.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index f98e151..ce43184 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -481,6 +481,7 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.get_wol = stmmac_get_wol,
 	.set_wol = stmmac_set_wol,
 	.get_sset_count	= stmmac_get_sset_count,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
