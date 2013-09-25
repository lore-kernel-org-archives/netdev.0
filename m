From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/11] ipw2x00: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:24 -0700
Message-ID: <89eb744f1a77b32d6ec718618f356df3188403e7.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ipw2x00/libipw.h | 87 +++++++++++++++--------------------
 1 file changed, 38 insertions(+), 49 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index 6eede52..5ce2f59 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -950,66 +950,55 @@ static inline int libipw_is_cck_rate(u8 rate)
 }
 
 /* libipw.c */
-extern void free_libipw(struct net_device *dev, int monitor);
-extern struct net_device *alloc_libipw(int sizeof_priv, int monitor);
-extern int libipw_change_mtu(struct net_device *dev, int new_mtu);
+void free_libipw(struct net_device *dev, int monitor);
+struct net_device *alloc_libipw(int sizeof_priv, int monitor);
+int libipw_change_mtu(struct net_device *dev, int new_mtu);
 
-extern void libipw_networks_age(struct libipw_device *ieee,
-				   unsigned long age_secs);
+void libipw_networks_age(struct libipw_device *ieee, unsigned long age_secs);
 
-extern int libipw_set_encryption(struct libipw_device *ieee);
+int libipw_set_encryption(struct libipw_device *ieee);
 
 /* libipw_tx.c */
-extern netdev_tx_t libipw_xmit(struct sk_buff *skb,
-			       struct net_device *dev);
-extern void libipw_txb_free(struct libipw_txb *);
+netdev_tx_t libipw_xmit(struct sk_buff *skb, struct net_device *dev);
+void libipw_txb_free(struct libipw_txb *);
 
 /* libipw_rx.c */
-extern void libipw_rx_any(struct libipw_device *ieee,
-		     struct sk_buff *skb, struct libipw_rx_stats *stats);
-extern int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
-			struct libipw_rx_stats *rx_stats);
+void libipw_rx_any(struct libipw_device *ieee, struct sk_buff *skb,
+		   struct libipw_rx_stats *stats);
+int libipw_rx(struct libipw_device *ieee, struct sk_buff *skb,
+	      struct libipw_rx_stats *rx_stats);
 /* make sure to set stats->len */
-extern void libipw_rx_mgt(struct libipw_device *ieee,
-			     struct libipw_hdr_4addr *header,
-			     struct libipw_rx_stats *stats);
-extern void libipw_network_reset(struct libipw_network *network);
+void libipw_rx_mgt(struct libipw_device *ieee, struct libipw_hdr_4addr *header,
+		   struct libipw_rx_stats *stats);
+void libipw_network_reset(struct libipw_network *network);
 
 /* libipw_geo.c */
-extern const struct libipw_geo *libipw_get_geo(struct libipw_device
-						     *ieee);
-extern void libipw_set_geo(struct libipw_device *ieee,
-			     const struct libipw_geo *geo);
-
-extern int libipw_is_valid_channel(struct libipw_device *ieee,
-				      u8 channel);
-extern int libipw_channel_to_index(struct libipw_device *ieee,
-				      u8 channel);
-extern u8 libipw_freq_to_channel(struct libipw_device *ieee, u32 freq);
-extern u8 libipw_get_channel_flags(struct libipw_device *ieee,
-				      u8 channel);
-extern const struct libipw_channel *libipw_get_channel(struct
-							     libipw_device
-							     *ieee, u8 channel);
-extern u32 libipw_channel_to_freq(struct libipw_device * ieee,
-				      u8 channel);
+const struct libipw_geo *libipw_get_geo(struct libipw_device *ieee);
+void libipw_set_geo(struct libipw_device *ieee, const struct libipw_geo *geo);
+
+int libipw_is_valid_channel(struct libipw_device *ieee, u8 channel);
+int libipw_channel_to_index(struct libipw_device *ieee, u8 channel);
+u8 libipw_freq_to_channel(struct libipw_device *ieee, u32 freq);
+u8 libipw_get_channel_flags(struct libipw_device *ieee, u8 channel);
+const struct libipw_channel *libipw_get_channel(struct libipw_device *ieee,
+						u8 channel);
+u32 libipw_channel_to_freq(struct libipw_device *ieee, u8 channel);
 
 /* libipw_wx.c */
-extern int libipw_wx_get_scan(struct libipw_device *ieee,
-				 struct iw_request_info *info,
-				 union iwreq_data *wrqu, char *key);
-extern int libipw_wx_set_encode(struct libipw_device *ieee,
-				   struct iw_request_info *info,
-				   union iwreq_data *wrqu, char *key);
-extern int libipw_wx_get_encode(struct libipw_device *ieee,
-				   struct iw_request_info *info,
-				   union iwreq_data *wrqu, char *key);
-extern int libipw_wx_set_encodeext(struct libipw_device *ieee,
-				      struct iw_request_info *info,
-				      union iwreq_data *wrqu, char *extra);
-extern int libipw_wx_get_encodeext(struct libipw_device *ieee,
-				      struct iw_request_info *info,
-				      union iwreq_data *wrqu, char *extra);
+int libipw_wx_get_scan(struct libipw_device *ieee, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *key);
+int libipw_wx_set_encode(struct libipw_device *ieee,
+			 struct iw_request_info *info, union iwreq_data *wrqu,
+			 char *key);
+int libipw_wx_get_encode(struct libipw_device *ieee,
+			 struct iw_request_info *info, union iwreq_data *wrqu,
+			 char *key);
+int libipw_wx_set_encodeext(struct libipw_device *ieee,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *extra);
+int libipw_wx_get_encodeext(struct libipw_device *ieee,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *extra);
 
 static inline void libipw_increment_scans(struct libipw_device *ieee)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
