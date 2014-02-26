From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 4/8] 6lowpan: change tag
	type to __be16
Date: Wed, 26 Feb 2014 17:05:08 +0100
Message-ID: <1393430712-11298-5-git-send-email-alex.aring@gmail.com>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393430712-11298-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 872c8f9..6b7d17f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -68,7 +68,7 @@ static LIST_HEAD(lowpan_devices);
 struct lowpan_dev_info {
 	struct net_device	*real_dev; /* real WPAN device ptr */
 	struct mutex		dev_list_mtx; /* mutex for list ops */
-	unsigned short		fragment_tag;
+	__be16			fragment_tag;
 };
 
 struct lowpan_dev_record {
@@ -424,7 +424,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
 	u16 dgram_offset, dgram_size, payload_length, header_length,
-	    lowpan_size, frag_plen, offset, tag;
+	    lowpan_size, frag_plen, offset;
+	__be16 tag;
 	u8 head[5];
 
 	header_length = skb->mac_len;
-- 
1.9.0


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
