From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 26/28] tg3: Support the
	get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:20:11 +0200
Message-ID: <b417fa1e245dbb0691d22e1b8ec0954b19bcce43.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/broadcom/tg3.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7b71387..8609798 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12233,6 +12233,7 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_rxfh_indir_size    = tg3_get_rxfh_indir_size,
 	.get_rxfh_indir		= tg3_get_rxfh_indir,
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-- 
1.7.2.5


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
