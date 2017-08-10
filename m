From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 06/10] netvsc: whitespace cleanup
Date: Wed,  9 Aug 2017 17:46:08 -0700
Message-ID: <20170810004612.22163-7-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Fix some minor indentation issues.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c7391889938b..3219d2e8918f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -165,7 +165,7 @@ static int netvsc_close(struct net_device *net)
 }
 
 static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,
-				int pkt_type)
+			   int pkt_type)
 {
 	struct rndis_packet *rndis_pkt;
 	struct rndis_per_packet_info *ppi;
@@ -286,7 +286,7 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 }
 
 static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
-			struct hv_page_buffer *pb)
+		       struct hv_page_buffer *pb)
 {
 	int j = 0;
 
@@ -626,6 +626,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	++net_device_ctx->eth_stats.tx_no_memory;
 	goto drop;
 }
+
 /*
  * netvsc_linkstatus_callback - Link up/down notification
  */
@@ -649,8 +650,8 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 	if (indicate->status == RNDIS_STATUS_LINK_SPEED_CHANGE) {
 		u32 speed;
 
-		speed = *(u32 *)((void *)indicate + indicate->
-				 status_buf_offset) / 10000;
+		speed = *(u32 *)((void *)indicate
+				 + indicate->status_buf_offset) / 10000;
 		ndev_ctx->speed = speed;
 		return;
 	}
@@ -1018,7 +1019,7 @@ static void netvsc_get_stats64(struct net_device *net,
 	struct net_device_context *ndev_ctx = netdev_priv(net);
 	struct netvsc_device *nvdev = rcu_dereference_rtnl(ndev_ctx->nvdev);
 	struct netvsc_vf_pcpu_stats vf_tot;
-		int i;
+	int i;
 
 	if (!nvdev)
 		return;
-- 
2.11.0
