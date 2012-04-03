From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 20/28] pxa168_eth: Support the
	get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:44 +0200
Message-ID: <0f46b95d36a5d765cb08cc4d800f713239d8e8d6.1333474524.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/marvell/pxa168_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 45a6333..44bad60 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1457,6 +1457,7 @@ static const struct ethtool_ops pxa168_ethtool_ops = {
 	.set_settings = pxa168_set_settings,
 	.get_drvinfo = pxa168_get_drvinfo,
 	.get_link = ethtool_op_get_link,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 static const struct net_device_ops pxa168_eth_netdev_ops = {
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
