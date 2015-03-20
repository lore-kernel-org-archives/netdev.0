From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 4/5] net: netcp: enclose macros in parentheses
Date: Fri, 20 Mar 2015 16:11:24 -0400
Message-ID: <1426882285-4873-5-git-send-email-m-karicheri2@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	WingMan Kwok <w-kwok2@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Christoph Jaeger <cj@linux.com>,
	Lokesh Vutla <lokeshvutla@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix following checkpatch error. It seems to have passed checkpatch
last time when original code was introduced.

 ERROR: Macros with complex values should be enclosed in parentheses
 #172: FILE: drivers/net/ethernet/ti/netcp_ethss.c:869:

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Mugunthan V N <mugunthanvnm@ti.com>
CC: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: Christoph Jaeger <cj@linux.com>
CC: Lokesh Vutla <lokeshvutla@ti.com>
CC: Markus Pargmann <mpa@pengutronix.de>
CC: Kumar Gala <galak@codeaurora.org>
CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
CC: Mark Rutland <mark.rutland@arm.com>
CC: Pawel Moll <pawel.moll@arm.com>
CC: Rob Herring <robh+dt@kernel.org>

---
 drivers/net/ethernet/ti/netcp_ethss.c |  523 +++++++++++++++++----------------
 1 file changed, 272 insertions(+), 251 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 42592b8..f8f3be3 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -482,275 +482,296 @@ struct netcp_ethtool_stat {
 	int offset;
 };
 
-#define GBE_STATSA_INFO(field)		"GBE_A:"#field, GBE_STATSA_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
+#define GBE_STATSA_INFO(field)						\
+{									\
+	"GBE_A:"#field, GBE_STATSA_MODULE,				\
+	FIELD_SIZEOF(struct gbe_hw_stats, field),			\
+	offsetof(struct gbe_hw_stats, field)				\
+}
 
-#define GBE_STATSB_INFO(field)		"GBE_B:"#field, GBE_STATSB_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
+#define GBE_STATSB_INFO(field)						\
+{									\
+	"GBE_B:"#field, GBE_STATSB_MODULE,				\
+	FIELD_SIZEOF(struct gbe_hw_stats, field),			\
+	offsetof(struct gbe_hw_stats, field)				\
+}
 
-#define GBE_STATSC_INFO(field)		"GBE_C:"#field, GBE_STATSC_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
+#define GBE_STATSC_INFO(field)						\
+{									\
+	"GBE_C:"#field, GBE_STATSC_MODULE,				\
+	FIELD_SIZEOF(struct gbe_hw_stats, field),			\
+	offsetof(struct gbe_hw_stats, field)				\
+}
 
-#define GBE_STATSD_INFO(field)		"GBE_D:"#field, GBE_STATSD_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
+#define GBE_STATSD_INFO(field)						\
+{									\
+	"GBE_D:"#field, GBE_STATSD_MODULE,				\
+	FIELD_SIZEOF(struct gbe_hw_stats, field),			\
+	offsetof(struct gbe_hw_stats, field)				\
+}
 
 static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	/* GBE module A */
-	{GBE_STATSA_INFO(rx_good_frames)},
-	{GBE_STATSA_INFO(rx_broadcast_frames)},
-	{GBE_STATSA_INFO(rx_multicast_frames)},
-	{GBE_STATSA_INFO(rx_pause_frames)},
-	{GBE_STATSA_INFO(rx_crc_errors)},
-	{GBE_STATSA_INFO(rx_align_code_errors)},
-	{GBE_STATSA_INFO(rx_oversized_frames)},
-	{GBE_STATSA_INFO(rx_jabber_frames)},
-	{GBE_STATSA_INFO(rx_undersized_frames)},
-	{GBE_STATSA_INFO(rx_fragments)},
-	{GBE_STATSA_INFO(rx_bytes)},
-	{GBE_STATSA_INFO(tx_good_frames)},
-	{GBE_STATSA_INFO(tx_broadcast_frames)},
-	{GBE_STATSA_INFO(tx_multicast_frames)},
-	{GBE_STATSA_INFO(tx_pause_frames)},
-	{GBE_STATSA_INFO(tx_deferred_frames)},
-	{GBE_STATSA_INFO(tx_collision_frames)},
-	{GBE_STATSA_INFO(tx_single_coll_frames)},
-	{GBE_STATSA_INFO(tx_mult_coll_frames)},
-	{GBE_STATSA_INFO(tx_excessive_collisions)},
-	{GBE_STATSA_INFO(tx_late_collisions)},
-	{GBE_STATSA_INFO(tx_underrun)},
-	{GBE_STATSA_INFO(tx_carrier_sense_errors)},
-	{GBE_STATSA_INFO(tx_bytes)},
-	{GBE_STATSA_INFO(tx_64byte_frames)},
-	{GBE_STATSA_INFO(tx_65_to_127byte_frames)},
-	{GBE_STATSA_INFO(tx_128_to_255byte_frames)},
-	{GBE_STATSA_INFO(tx_256_to_511byte_frames)},
-	{GBE_STATSA_INFO(tx_512_to_1023byte_frames)},
-	{GBE_STATSA_INFO(tx_1024byte_frames)},
-	{GBE_STATSA_INFO(net_bytes)},
-	{GBE_STATSA_INFO(rx_sof_overruns)},
-	{GBE_STATSA_INFO(rx_mof_overruns)},
-	{GBE_STATSA_INFO(rx_dma_overruns)},
+	GBE_STATSA_INFO(rx_good_frames),
+	GBE_STATSA_INFO(rx_broadcast_frames),
+	GBE_STATSA_INFO(rx_multicast_frames),
+	GBE_STATSA_INFO(rx_pause_frames),
+	GBE_STATSA_INFO(rx_crc_errors),
+	GBE_STATSA_INFO(rx_align_code_errors),
+	GBE_STATSA_INFO(rx_oversized_frames),
+	GBE_STATSA_INFO(rx_jabber_frames),
+	GBE_STATSA_INFO(rx_undersized_frames),
+	GBE_STATSA_INFO(rx_fragments),
+	GBE_STATSA_INFO(rx_bytes),
+	GBE_STATSA_INFO(tx_good_frames),
+	GBE_STATSA_INFO(tx_broadcast_frames),
+	GBE_STATSA_INFO(tx_multicast_frames),
+	GBE_STATSA_INFO(tx_pause_frames),
+	GBE_STATSA_INFO(tx_deferred_frames),
+	GBE_STATSA_INFO(tx_collision_frames),
+	GBE_STATSA_INFO(tx_single_coll_frames),
+	GBE_STATSA_INFO(tx_mult_coll_frames),
+	GBE_STATSA_INFO(tx_excessive_collisions),
+	GBE_STATSA_INFO(tx_late_collisions),
+	GBE_STATSA_INFO(tx_underrun),
+	GBE_STATSA_INFO(tx_carrier_sense_errors),
+	GBE_STATSA_INFO(tx_bytes),
+	GBE_STATSA_INFO(tx_64byte_frames),
+	GBE_STATSA_INFO(tx_65_to_127byte_frames),
+	GBE_STATSA_INFO(tx_128_to_255byte_frames),
+	GBE_STATSA_INFO(tx_256_to_511byte_frames),
+	GBE_STATSA_INFO(tx_512_to_1023byte_frames),
+	GBE_STATSA_INFO(tx_1024byte_frames),
+	GBE_STATSA_INFO(net_bytes),
+	GBE_STATSA_INFO(rx_sof_overruns),
+	GBE_STATSA_INFO(rx_mof_overruns),
+	GBE_STATSA_INFO(rx_dma_overruns),
 	/* GBE module B */
-	{GBE_STATSB_INFO(rx_good_frames)},
-	{GBE_STATSB_INFO(rx_broadcast_frames)},
-	{GBE_STATSB_INFO(rx_multicast_frames)},
-	{GBE_STATSB_INFO(rx_pause_frames)},
-	{GBE_STATSB_INFO(rx_crc_errors)},
-	{GBE_STATSB_INFO(rx_align_code_errors)},
-	{GBE_STATSB_INFO(rx_oversized_frames)},
-	{GBE_STATSB_INFO(rx_jabber_frames)},
-	{GBE_STATSB_INFO(rx_undersized_frames)},
-	{GBE_STATSB_INFO(rx_fragments)},
-	{GBE_STATSB_INFO(rx_bytes)},
-	{GBE_STATSB_INFO(tx_good_frames)},
-	{GBE_STATSB_INFO(tx_broadcast_frames)},
-	{GBE_STATSB_INFO(tx_multicast_frames)},
-	{GBE_STATSB_INFO(tx_pause_frames)},
-	{GBE_STATSB_INFO(tx_deferred_frames)},
-	{GBE_STATSB_INFO(tx_collision_frames)},
-	{GBE_STATSB_INFO(tx_single_coll_frames)},
-	{GBE_STATSB_INFO(tx_mult_coll_frames)},
-	{GBE_STATSB_INFO(tx_excessive_collisions)},
-	{GBE_STATSB_INFO(tx_late_collisions)},
-	{GBE_STATSB_INFO(tx_underrun)},
-	{GBE_STATSB_INFO(tx_carrier_sense_errors)},
-	{GBE_STATSB_INFO(tx_bytes)},
-	{GBE_STATSB_INFO(tx_64byte_frames)},
-	{GBE_STATSB_INFO(tx_65_to_127byte_frames)},
-	{GBE_STATSB_INFO(tx_128_to_255byte_frames)},
-	{GBE_STATSB_INFO(tx_256_to_511byte_frames)},
-	{GBE_STATSB_INFO(tx_512_to_1023byte_frames)},
-	{GBE_STATSB_INFO(tx_1024byte_frames)},
-	{GBE_STATSB_INFO(net_bytes)},
-	{GBE_STATSB_INFO(rx_sof_overruns)},
-	{GBE_STATSB_INFO(rx_mof_overruns)},
-	{GBE_STATSB_INFO(rx_dma_overruns)},
+	GBE_STATSB_INFO(rx_good_frames),
+	GBE_STATSB_INFO(rx_broadcast_frames),
+	GBE_STATSB_INFO(rx_multicast_frames),
+	GBE_STATSB_INFO(rx_pause_frames),
+	GBE_STATSB_INFO(rx_crc_errors),
+	GBE_STATSB_INFO(rx_align_code_errors),
+	GBE_STATSB_INFO(rx_oversized_frames),
+	GBE_STATSB_INFO(rx_jabber_frames),
+	GBE_STATSB_INFO(rx_undersized_frames),
+	GBE_STATSB_INFO(rx_fragments),
+	GBE_STATSB_INFO(rx_bytes),
+	GBE_STATSB_INFO(tx_good_frames),
+	GBE_STATSB_INFO(tx_broadcast_frames),
+	GBE_STATSB_INFO(tx_multicast_frames),
+	GBE_STATSB_INFO(tx_pause_frames),
+	GBE_STATSB_INFO(tx_deferred_frames),
+	GBE_STATSB_INFO(tx_collision_frames),
+	GBE_STATSB_INFO(tx_single_coll_frames),
+	GBE_STATSB_INFO(tx_mult_coll_frames),
+	GBE_STATSB_INFO(tx_excessive_collisions),
+	GBE_STATSB_INFO(tx_late_collisions),
+	GBE_STATSB_INFO(tx_underrun),
+	GBE_STATSB_INFO(tx_carrier_sense_errors),
+	GBE_STATSB_INFO(tx_bytes),
+	GBE_STATSB_INFO(tx_64byte_frames),
+	GBE_STATSB_INFO(tx_65_to_127byte_frames),
+	GBE_STATSB_INFO(tx_128_to_255byte_frames),
+	GBE_STATSB_INFO(tx_256_to_511byte_frames),
+	GBE_STATSB_INFO(tx_512_to_1023byte_frames),
+	GBE_STATSB_INFO(tx_1024byte_frames),
+	GBE_STATSB_INFO(net_bytes),
+	GBE_STATSB_INFO(rx_sof_overruns),
+	GBE_STATSB_INFO(rx_mof_overruns),
+	GBE_STATSB_INFO(rx_dma_overruns),
 	/* GBE module C */
-	{GBE_STATSC_INFO(rx_good_frames)},
-	{GBE_STATSC_INFO(rx_broadcast_frames)},
-	{GBE_STATSC_INFO(rx_multicast_frames)},
-	{GBE_STATSC_INFO(rx_pause_frames)},
-	{GBE_STATSC_INFO(rx_crc_errors)},
-	{GBE_STATSC_INFO(rx_align_code_errors)},
-	{GBE_STATSC_INFO(rx_oversized_frames)},
-	{GBE_STATSC_INFO(rx_jabber_frames)},
-	{GBE_STATSC_INFO(rx_undersized_frames)},
-	{GBE_STATSC_INFO(rx_fragments)},
-	{GBE_STATSC_INFO(rx_bytes)},
-	{GBE_STATSC_INFO(tx_good_frames)},
-	{GBE_STATSC_INFO(tx_broadcast_frames)},
-	{GBE_STATSC_INFO(tx_multicast_frames)},
-	{GBE_STATSC_INFO(tx_pause_frames)},
-	{GBE_STATSC_INFO(tx_deferred_frames)},
-	{GBE_STATSC_INFO(tx_collision_frames)},
-	{GBE_STATSC_INFO(tx_single_coll_frames)},
-	{GBE_STATSC_INFO(tx_mult_coll_frames)},
-	{GBE_STATSC_INFO(tx_excessive_collisions)},
-	{GBE_STATSC_INFO(tx_late_collisions)},
-	{GBE_STATSC_INFO(tx_underrun)},
-	{GBE_STATSC_INFO(tx_carrier_sense_errors)},
-	{GBE_STATSC_INFO(tx_bytes)},
-	{GBE_STATSC_INFO(tx_64byte_frames)},
-	{GBE_STATSC_INFO(tx_65_to_127byte_frames)},
-	{GBE_STATSC_INFO(tx_128_to_255byte_frames)},
-	{GBE_STATSC_INFO(tx_256_to_511byte_frames)},
-	{GBE_STATSC_INFO(tx_512_to_1023byte_frames)},
-	{GBE_STATSC_INFO(tx_1024byte_frames)},
-	{GBE_STATSC_INFO(net_bytes)},
-	{GBE_STATSC_INFO(rx_sof_overruns)},
-	{GBE_STATSC_INFO(rx_mof_overruns)},
-	{GBE_STATSC_INFO(rx_dma_overruns)},
+	GBE_STATSC_INFO(rx_good_frames),
+	GBE_STATSC_INFO(rx_broadcast_frames),
+	GBE_STATSC_INFO(rx_multicast_frames),
+	GBE_STATSC_INFO(rx_pause_frames),
+	GBE_STATSC_INFO(rx_crc_errors),
+	GBE_STATSC_INFO(rx_align_code_errors),
+	GBE_STATSC_INFO(rx_oversized_frames),
+	GBE_STATSC_INFO(rx_jabber_frames),
+	GBE_STATSC_INFO(rx_undersized_frames),
+	GBE_STATSC_INFO(rx_fragments),
+	GBE_STATSC_INFO(rx_bytes),
+	GBE_STATSC_INFO(tx_good_frames),
+	GBE_STATSC_INFO(tx_broadcast_frames),
+	GBE_STATSC_INFO(tx_multicast_frames),
+	GBE_STATSC_INFO(tx_pause_frames),
+	GBE_STATSC_INFO(tx_deferred_frames),
+	GBE_STATSC_INFO(tx_collision_frames),
+	GBE_STATSC_INFO(tx_single_coll_frames),
+	GBE_STATSC_INFO(tx_mult_coll_frames),
+	GBE_STATSC_INFO(tx_excessive_collisions),
+	GBE_STATSC_INFO(tx_late_collisions),
+	GBE_STATSC_INFO(tx_underrun),
+	GBE_STATSC_INFO(tx_carrier_sense_errors),
+	GBE_STATSC_INFO(tx_bytes),
+	GBE_STATSC_INFO(tx_64byte_frames),
+	GBE_STATSC_INFO(tx_65_to_127byte_frames),
+	GBE_STATSC_INFO(tx_128_to_255byte_frames),
+	GBE_STATSC_INFO(tx_256_to_511byte_frames),
+	GBE_STATSC_INFO(tx_512_to_1023byte_frames),
+	GBE_STATSC_INFO(tx_1024byte_frames),
+	GBE_STATSC_INFO(net_bytes),
+	GBE_STATSC_INFO(rx_sof_overruns),
+	GBE_STATSC_INFO(rx_mof_overruns),
+	GBE_STATSC_INFO(rx_dma_overruns),
 	/* GBE module D */
-	{GBE_STATSD_INFO(rx_good_frames)},
-	{GBE_STATSD_INFO(rx_broadcast_frames)},
-	{GBE_STATSD_INFO(rx_multicast_frames)},
-	{GBE_STATSD_INFO(rx_pause_frames)},
-	{GBE_STATSD_INFO(rx_crc_errors)},
-	{GBE_STATSD_INFO(rx_align_code_errors)},
-	{GBE_STATSD_INFO(rx_oversized_frames)},
-	{GBE_STATSD_INFO(rx_jabber_frames)},
-	{GBE_STATSD_INFO(rx_undersized_frames)},
-	{GBE_STATSD_INFO(rx_fragments)},
-	{GBE_STATSD_INFO(rx_bytes)},
-	{GBE_STATSD_INFO(tx_good_frames)},
-	{GBE_STATSD_INFO(tx_broadcast_frames)},
-	{GBE_STATSD_INFO(tx_multicast_frames)},
-	{GBE_STATSD_INFO(tx_pause_frames)},
-	{GBE_STATSD_INFO(tx_deferred_frames)},
-	{GBE_STATSD_INFO(tx_collision_frames)},
-	{GBE_STATSD_INFO(tx_single_coll_frames)},
-	{GBE_STATSD_INFO(tx_mult_coll_frames)},
-	{GBE_STATSD_INFO(tx_excessive_collisions)},
-	{GBE_STATSD_INFO(tx_late_collisions)},
-	{GBE_STATSD_INFO(tx_underrun)},
-	{GBE_STATSD_INFO(tx_carrier_sense_errors)},
-	{GBE_STATSD_INFO(tx_bytes)},
-	{GBE_STATSD_INFO(tx_64byte_frames)},
-	{GBE_STATSD_INFO(tx_65_to_127byte_frames)},
-	{GBE_STATSD_INFO(tx_128_to_255byte_frames)},
-	{GBE_STATSD_INFO(tx_256_to_511byte_frames)},
-	{GBE_STATSD_INFO(tx_512_to_1023byte_frames)},
-	{GBE_STATSD_INFO(tx_1024byte_frames)},
-	{GBE_STATSD_INFO(net_bytes)},
-	{GBE_STATSD_INFO(rx_sof_overruns)},
-	{GBE_STATSD_INFO(rx_mof_overruns)},
-	{GBE_STATSD_INFO(rx_dma_overruns)},
+	GBE_STATSD_INFO(rx_good_frames),
+	GBE_STATSD_INFO(rx_broadcast_frames),
+	GBE_STATSD_INFO(rx_multicast_frames),
+	GBE_STATSD_INFO(rx_pause_frames),
+	GBE_STATSD_INFO(rx_crc_errors),
+	GBE_STATSD_INFO(rx_align_code_errors),
+	GBE_STATSD_INFO(rx_oversized_frames),
+	GBE_STATSD_INFO(rx_jabber_frames),
+	GBE_STATSD_INFO(rx_undersized_frames),
+	GBE_STATSD_INFO(rx_fragments),
+	GBE_STATSD_INFO(rx_bytes),
+	GBE_STATSD_INFO(tx_good_frames),
+	GBE_STATSD_INFO(tx_broadcast_frames),
+	GBE_STATSD_INFO(tx_multicast_frames),
+	GBE_STATSD_INFO(tx_pause_frames),
+	GBE_STATSD_INFO(tx_deferred_frames),
+	GBE_STATSD_INFO(tx_collision_frames),
+	GBE_STATSD_INFO(tx_single_coll_frames),
+	GBE_STATSD_INFO(tx_mult_coll_frames),
+	GBE_STATSD_INFO(tx_excessive_collisions),
+	GBE_STATSD_INFO(tx_late_collisions),
+	GBE_STATSD_INFO(tx_underrun),
+	GBE_STATSD_INFO(tx_carrier_sense_errors),
+	GBE_STATSD_INFO(tx_bytes),
+	GBE_STATSD_INFO(tx_64byte_frames),
+	GBE_STATSD_INFO(tx_65_to_127byte_frames),
+	GBE_STATSD_INFO(tx_128_to_255byte_frames),
+	GBE_STATSD_INFO(tx_256_to_511byte_frames),
+	GBE_STATSD_INFO(tx_512_to_1023byte_frames),
+	GBE_STATSD_INFO(tx_1024byte_frames),
+	GBE_STATSD_INFO(net_bytes),
+	GBE_STATSD_INFO(rx_sof_overruns),
+	GBE_STATSD_INFO(rx_mof_overruns),
+	GBE_STATSD_INFO(rx_dma_overruns),
 };
 
-#define XGBE_STATS0_INFO(field)	"GBE_0:"#field, XGBE_STATS0_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS0_INFO(field)				\
+{							\
+	"GBE_0:"#field, XGBE_STATS0_MODULE,		\
+	FIELD_SIZEOF(struct xgbe_hw_stats, field),	\
+	offsetof(struct xgbe_hw_stats, field)		\
+}
 
-#define XGBE_STATS1_INFO(field)	"GBE_1:"#field, XGBE_STATS1_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS1_INFO(field)				\
+{							\
+	"GBE_1:"#field, XGBE_STATS1_MODULE,		\
+	FIELD_SIZEOF(struct xgbe_hw_stats, field),	\
+	offsetof(struct xgbe_hw_stats, field)		\
+}
 
-#define XGBE_STATS2_INFO(field)	"GBE_2:"#field, XGBE_STATS2_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS2_INFO(field)				\
+{							\
+	"GBE_2:"#field, XGBE_STATS2_MODULE,		\
+	FIELD_SIZEOF(struct xgbe_hw_stats, field),	\
+	offsetof(struct xgbe_hw_stats, field)		\
+}
 
 static const struct netcp_ethtool_stat xgbe10_et_stats[] = {
 	/* GBE module 0 */
-	{XGBE_STATS0_INFO(rx_good_frames)},
-	{XGBE_STATS0_INFO(rx_broadcast_frames)},
-	{XGBE_STATS0_INFO(rx_multicast_frames)},
-	{XGBE_STATS0_INFO(rx_oversized_frames)},
-	{XGBE_STATS0_INFO(rx_undersized_frames)},
-	{XGBE_STATS0_INFO(overrun_type4)},
-	{XGBE_STATS0_INFO(overrun_type5)},
-	{XGBE_STATS0_INFO(rx_bytes)},
-	{XGBE_STATS0_INFO(tx_good_frames)},
-	{XGBE_STATS0_INFO(tx_broadcast_frames)},
-	{XGBE_STATS0_INFO(tx_multicast_frames)},
-	{XGBE_STATS0_INFO(tx_bytes)},
-	{XGBE_STATS0_INFO(tx_64byte_frames)},
-	{XGBE_STATS0_INFO(tx_65_to_127byte_frames)},
-	{XGBE_STATS0_INFO(tx_128_to_255byte_frames)},
-	{XGBE_STATS0_INFO(tx_256_to_511byte_frames)},
-	{XGBE_STATS0_INFO(tx_512_to_1023byte_frames)},
-	{XGBE_STATS0_INFO(tx_1024byte_frames)},
-	{XGBE_STATS0_INFO(net_bytes)},
-	{XGBE_STATS0_INFO(rx_sof_overruns)},
-	{XGBE_STATS0_INFO(rx_mof_overruns)},
-	{XGBE_STATS0_INFO(rx_dma_overruns)},
+	XGBE_STATS0_INFO(rx_good_frames),
+	XGBE_STATS0_INFO(rx_broadcast_frames),
+	XGBE_STATS0_INFO(rx_multicast_frames),
+	XGBE_STATS0_INFO(rx_oversized_frames),
+	XGBE_STATS0_INFO(rx_undersized_frames),
+	XGBE_STATS0_INFO(overrun_type4),
+	XGBE_STATS0_INFO(overrun_type5),
+	XGBE_STATS0_INFO(rx_bytes),
+	XGBE_STATS0_INFO(tx_good_frames),
+	XGBE_STATS0_INFO(tx_broadcast_frames),
+	XGBE_STATS0_INFO(tx_multicast_frames),
+	XGBE_STATS0_INFO(tx_bytes),
+	XGBE_STATS0_INFO(tx_64byte_frames),
+	XGBE_STATS0_INFO(tx_65_to_127byte_frames),
+	XGBE_STATS0_INFO(tx_128_to_255byte_frames),
+	XGBE_STATS0_INFO(tx_256_to_511byte_frames),
+	XGBE_STATS0_INFO(tx_512_to_1023byte_frames),
+	XGBE_STATS0_INFO(tx_1024byte_frames),
+	XGBE_STATS0_INFO(net_bytes),
+	XGBE_STATS0_INFO(rx_sof_overruns),
+	XGBE_STATS0_INFO(rx_mof_overruns),
+	XGBE_STATS0_INFO(rx_dma_overruns),
 	/* XGBE module 1 */
-	{XGBE_STATS1_INFO(rx_good_frames)},
-	{XGBE_STATS1_INFO(rx_broadcast_frames)},
-	{XGBE_STATS1_INFO(rx_multicast_frames)},
-	{XGBE_STATS1_INFO(rx_pause_frames)},
-	{XGBE_STATS1_INFO(rx_crc_errors)},
-	{XGBE_STATS1_INFO(rx_align_code_errors)},
-	{XGBE_STATS1_INFO(rx_oversized_frames)},
-	{XGBE_STATS1_INFO(rx_jabber_frames)},
-	{XGBE_STATS1_INFO(rx_undersized_frames)},
-	{XGBE_STATS1_INFO(rx_fragments)},
-	{XGBE_STATS1_INFO(overrun_type4)},
-	{XGBE_STATS1_INFO(overrun_type5)},
-	{XGBE_STATS1_INFO(rx_bytes)},
-	{XGBE_STATS1_INFO(tx_good_frames)},
-	{XGBE_STATS1_INFO(tx_broadcast_frames)},
-	{XGBE_STATS1_INFO(tx_multicast_frames)},
-	{XGBE_STATS1_INFO(tx_pause_frames)},
-	{XGBE_STATS1_INFO(tx_deferred_frames)},
-	{XGBE_STATS1_INFO(tx_collision_frames)},
-	{XGBE_STATS1_INFO(tx_single_coll_frames)},
-	{XGBE_STATS1_INFO(tx_mult_coll_frames)},
-	{XGBE_STATS1_INFO(tx_excessive_collisions)},
-	{XGBE_STATS1_INFO(tx_late_collisions)},
-	{XGBE_STATS1_INFO(tx_underrun)},
-	{XGBE_STATS1_INFO(tx_carrier_sense_errors)},
-	{XGBE_STATS1_INFO(tx_bytes)},
-	{XGBE_STATS1_INFO(tx_64byte_frames)},
-	{XGBE_STATS1_INFO(tx_65_to_127byte_frames)},
-	{XGBE_STATS1_INFO(tx_128_to_255byte_frames)},
-	{XGBE_STATS1_INFO(tx_256_to_511byte_frames)},
-	{XGBE_STATS1_INFO(tx_512_to_1023byte_frames)},
-	{XGBE_STATS1_INFO(tx_1024byte_frames)},
-	{XGBE_STATS1_INFO(net_bytes)},
-	{XGBE_STATS1_INFO(rx_sof_overruns)},
-	{XGBE_STATS1_INFO(rx_mof_overruns)},
-	{XGBE_STATS1_INFO(rx_dma_overruns)},
+	XGBE_STATS1_INFO(rx_good_frames),
+	XGBE_STATS1_INFO(rx_broadcast_frames),
+	XGBE_STATS1_INFO(rx_multicast_frames),
+	XGBE_STATS1_INFO(rx_pause_frames),
+	XGBE_STATS1_INFO(rx_crc_errors),
+	XGBE_STATS1_INFO(rx_align_code_errors),
+	XGBE_STATS1_INFO(rx_oversized_frames),
+	XGBE_STATS1_INFO(rx_jabber_frames),
+	XGBE_STATS1_INFO(rx_undersized_frames),
+	XGBE_STATS1_INFO(rx_fragments),
+	XGBE_STATS1_INFO(overrun_type4),
+	XGBE_STATS1_INFO(overrun_type5),
+	XGBE_STATS1_INFO(rx_bytes),
+	XGBE_STATS1_INFO(tx_good_frames),
+	XGBE_STATS1_INFO(tx_broadcast_frames),
+	XGBE_STATS1_INFO(tx_multicast_frames),
+	XGBE_STATS1_INFO(tx_pause_frames),
+	XGBE_STATS1_INFO(tx_deferred_frames),
+	XGBE_STATS1_INFO(tx_collision_frames),
+	XGBE_STATS1_INFO(tx_single_coll_frames),
+	XGBE_STATS1_INFO(tx_mult_coll_frames),
+	XGBE_STATS1_INFO(tx_excessive_collisions),
+	XGBE_STATS1_INFO(tx_late_collisions),
+	XGBE_STATS1_INFO(tx_underrun),
+	XGBE_STATS1_INFO(tx_carrier_sense_errors),
+	XGBE_STATS1_INFO(tx_bytes),
+	XGBE_STATS1_INFO(tx_64byte_frames),
+	XGBE_STATS1_INFO(tx_65_to_127byte_frames),
+	XGBE_STATS1_INFO(tx_128_to_255byte_frames),
+	XGBE_STATS1_INFO(tx_256_to_511byte_frames),
+	XGBE_STATS1_INFO(tx_512_to_1023byte_frames),
+	XGBE_STATS1_INFO(tx_1024byte_frames),
+	XGBE_STATS1_INFO(net_bytes),
+	XGBE_STATS1_INFO(rx_sof_overruns),
+	XGBE_STATS1_INFO(rx_mof_overruns),
+	XGBE_STATS1_INFO(rx_dma_overruns),
 	/* XGBE module 2 */
-	{XGBE_STATS2_INFO(rx_good_frames)},
-	{XGBE_STATS2_INFO(rx_broadcast_frames)},
-	{XGBE_STATS2_INFO(rx_multicast_frames)},
-	{XGBE_STATS2_INFO(rx_pause_frames)},
-	{XGBE_STATS2_INFO(rx_crc_errors)},
-	{XGBE_STATS2_INFO(rx_align_code_errors)},
-	{XGBE_STATS2_INFO(rx_oversized_frames)},
-	{XGBE_STATS2_INFO(rx_jabber_frames)},
-	{XGBE_STATS2_INFO(rx_undersized_frames)},
-	{XGBE_STATS2_INFO(rx_fragments)},
-	{XGBE_STATS2_INFO(overrun_type4)},
-	{XGBE_STATS2_INFO(overrun_type5)},
-	{XGBE_STATS2_INFO(rx_bytes)},
-	{XGBE_STATS2_INFO(tx_good_frames)},
-	{XGBE_STATS2_INFO(tx_broadcast_frames)},
-	{XGBE_STATS2_INFO(tx_multicast_frames)},
-	{XGBE_STATS2_INFO(tx_pause_frames)},
-	{XGBE_STATS2_INFO(tx_deferred_frames)},
-	{XGBE_STATS2_INFO(tx_collision_frames)},
-	{XGBE_STATS2_INFO(tx_single_coll_frames)},
-	{XGBE_STATS2_INFO(tx_mult_coll_frames)},
-	{XGBE_STATS2_INFO(tx_excessive_collisions)},
-	{XGBE_STATS2_INFO(tx_late_collisions)},
-	{XGBE_STATS2_INFO(tx_underrun)},
-	{XGBE_STATS2_INFO(tx_carrier_sense_errors)},
-	{XGBE_STATS2_INFO(tx_bytes)},
-	{XGBE_STATS2_INFO(tx_64byte_frames)},
-	{XGBE_STATS2_INFO(tx_65_to_127byte_frames)},
-	{XGBE_STATS2_INFO(tx_128_to_255byte_frames)},
-	{XGBE_STATS2_INFO(tx_256_to_511byte_frames)},
-	{XGBE_STATS2_INFO(tx_512_to_1023byte_frames)},
-	{XGBE_STATS2_INFO(tx_1024byte_frames)},
-	{XGBE_STATS2_INFO(net_bytes)},
-	{XGBE_STATS2_INFO(rx_sof_overruns)},
-	{XGBE_STATS2_INFO(rx_mof_overruns)},
-	{XGBE_STATS2_INFO(rx_dma_overruns)},
+	XGBE_STATS2_INFO(rx_good_frames),
+	XGBE_STATS2_INFO(rx_broadcast_frames),
+	XGBE_STATS2_INFO(rx_multicast_frames),
+	XGBE_STATS2_INFO(rx_pause_frames),
+	XGBE_STATS2_INFO(rx_crc_errors),
+	XGBE_STATS2_INFO(rx_align_code_errors),
+	XGBE_STATS2_INFO(rx_oversized_frames),
+	XGBE_STATS2_INFO(rx_jabber_frames),
+	XGBE_STATS2_INFO(rx_undersized_frames),
+	XGBE_STATS2_INFO(rx_fragments),
+	XGBE_STATS2_INFO(overrun_type4),
+	XGBE_STATS2_INFO(overrun_type5),
+	XGBE_STATS2_INFO(rx_bytes),
+	XGBE_STATS2_INFO(tx_good_frames),
+	XGBE_STATS2_INFO(tx_broadcast_frames),
+	XGBE_STATS2_INFO(tx_multicast_frames),
+	XGBE_STATS2_INFO(tx_pause_frames),
+	XGBE_STATS2_INFO(tx_deferred_frames),
+	XGBE_STATS2_INFO(tx_collision_frames),
+	XGBE_STATS2_INFO(tx_single_coll_frames),
+	XGBE_STATS2_INFO(tx_mult_coll_frames),
+	XGBE_STATS2_INFO(tx_excessive_collisions),
+	XGBE_STATS2_INFO(tx_late_collisions),
+	XGBE_STATS2_INFO(tx_underrun),
+	XGBE_STATS2_INFO(tx_carrier_sense_errors),
+	XGBE_STATS2_INFO(tx_bytes),
+	XGBE_STATS2_INFO(tx_64byte_frames),
+	XGBE_STATS2_INFO(tx_65_to_127byte_frames),
+	XGBE_STATS2_INFO(tx_128_to_255byte_frames),
+	XGBE_STATS2_INFO(tx_256_to_511byte_frames),
+	XGBE_STATS2_INFO(tx_512_to_1023byte_frames),
+	XGBE_STATS2_INFO(tx_1024byte_frames),
+	XGBE_STATS2_INFO(net_bytes),
+	XGBE_STATS2_INFO(rx_sof_overruns),
+	XGBE_STATS2_INFO(rx_mof_overruns),
+	XGBE_STATS2_INFO(rx_dma_overruns),
 };
 
 #define for_each_intf(i, priv) \
-- 
1.7.9.5
