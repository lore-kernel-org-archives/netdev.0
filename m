From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 22/26] smsc9420: Support the
	get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:37 +0200
Message-ID: <9be82f2667faa9569386618c3851d5c4e5de1e31.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/smsc/smsc9420.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 3838647..f80ec68 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -469,6 +469,7 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.set_eeprom = smsc9420_ethtool_set_eeprom,
 	.get_regs_len = smsc9420_ethtool_getregslen,
 	.get_regs = smsc9420_ethtool_getregs,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 /* Sets the device MAC address to dev_addr */
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
