From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 30/31] staging: r8188eu: Fix sparse warnings in
 core/rtw_br_ext.c
Date: Sun, 22 Dec 2013 17:37:01 -0600
Message-ID: <1387755422-11443-31-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Sparse lists the following:

  CHECK   drivers/staging/rtl8188eu/core/rtw_br_ext.c
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:101: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:101:    expected unsigned int *ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:101:    got restricted __be32 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:123: warning: incorrect type in argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:123:    expected unsigned short *ipxSocketAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:700:123:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:99: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:99:    expected unsigned int *ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:99:    got restricted __be32 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:101: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:101:    expected unsigned int *ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:101:    got restricted __be32 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:121: warning: incorrect type in argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:121:    expected unsigned short *ipxSocketAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:714:121:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:721:99: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:721:99:    expected unsigned int *ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:721:99:    got restricted __be32 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:749:83: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:749:83:    expected unsigned short *network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:749:83:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:762:83: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:762:83:    expected unsigned short *network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:762:83:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:783:83: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:783:83:    expected unsigned short *network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:783:83:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:795:83: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:795:83:    expected unsigned short *network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:795:83:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:849:57: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:849:57:    expected unsigned short [unsigned] [short] <noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:849:57:    got restricted __be16 [usertype] <noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:92:23: warning: restricted __be16 degrades to integer
drivers/staging/rtl8188eu/core/rtw_br_ext.c:876:95: warning: incorrect type in argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:876:95:    expected unsigned short *sid
drivers/staging/rtl8188eu/core/rtw_br_ext.c:876:95:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:912:45: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:912:45: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:912:45: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:912:45: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:944:112: warning: incorrect type in argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:944:112:    expected unsigned short *sid
drivers/staging/rtl8188eu/core/rtw_br_ext.c:944:112:    got restricted __be16 *<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1019:84: warning: incorrect type in argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1019:84:    expected unsigned int [unsigned] [usertype] len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1019:84:    got restricted __be16 [usertype] payload_len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1021:110: warning: incorrect type in argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1021:110:    expected int [signed] len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1021:110:    got restricted __be16 [usertype] payload_len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1145:54: warning: cast to restricted __be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1148:70: warning: restricted __be16 degrades to integer
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1154:70: warning: invalid assignment: |=
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1154:70:    left side has type unsigned short
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1154:70:    right side has type restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1157:64: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1157:64: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1157:64: warning: cast to restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1157:64: warning: cast to restricted __be16

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_br_ext.c | 43 +++++++++++++++--------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_br_ext.c b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
index 5425bc5..75e38d4 100644
--- a/drivers/staging/rtl8188eu/core/rtw_br_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
@@ -89,7 +89,7 @@ static inline int __nat25_add_pppoe_tag(struct sk_buff *skb, struct pppoe_tag *t
 	struct pppoe_hdr *ph = (struct pppoe_hdr *)(skb->data + ETH_HLEN);
 	int data_len;
 
-	data_len = tag->tag_len + TAG_HDR_LEN;
+	data_len = be16_to_cpu(tag->tag_len) + TAG_HDR_LEN;
 	if (skb_tailroom(skb) < data_len) {
 		_DEBUG_ERR("skb_tailroom() failed in add SID tag!\n");
 		return -1;
@@ -155,7 +155,7 @@ static inline void __nat25_generate_ipv4_network_addr(unsigned char *networkAddr
 
 
 static inline void __nat25_generate_ipx_network_addr_with_node(unsigned char *networkAddr,
-				unsigned int *ipxNetAddr, unsigned char *ipxNodeAddr)
+				__be32 *ipxNetAddr, unsigned char *ipxNodeAddr)
 {
 	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
 
@@ -166,7 +166,7 @@ static inline void __nat25_generate_ipx_network_addr_with_node(unsigned char *ne
 
 
 static inline void __nat25_generate_ipx_network_addr_with_socket(unsigned char *networkAddr,
-				unsigned int *ipxNetAddr, unsigned short *ipxSocketAddr)
+				__be32 *ipxNetAddr, __be16 *ipxSocketAddr)
 {
 	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
 
@@ -177,7 +177,7 @@ static inline void __nat25_generate_ipx_network_addr_with_socket(unsigned char *
 
 
 static inline void __nat25_generate_apple_network_addr(unsigned char *networkAddr,
-				unsigned short *network, unsigned char *node)
+				__be16 *network, unsigned char *node)
 {
 	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
 
@@ -187,7 +187,7 @@ static inline void __nat25_generate_apple_network_addr(unsigned char *networkAdd
 }
 
 static inline void __nat25_generate_pppoe_network_addr(unsigned char *networkAddr,
-				unsigned char *ac_mac, unsigned short *sid)
+				unsigned char *ac_mac, __be16 *sid)
 {
 	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
 
@@ -197,7 +197,7 @@ static inline void __nat25_generate_pppoe_network_addr(unsigned char *networkAdd
 }
 
 static  void __nat25_generate_ipv6_network_addr(unsigned char *networkAddr,
-				unsigned int *ipAddr)
+				__be32 *ipAddr)
 {
 	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
 
@@ -807,7 +807,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 		/*                Handle PPPoE frame                 */
 		/*---------------------------------------------------*/
 		struct pppoe_hdr *ph = (struct pppoe_hdr *)(skb->data + ETH_HLEN);
-		unsigned short *pMagic;
+		__be16 *pMagic;
 
 		switch (method) {
 		case NAT25_CHECK:
@@ -845,7 +845,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 						tag->tag_len = htons(MAGIC_CODE_LEN+RTL_RELAY_TAG_LEN+old_tag_len);
 
 						/*  insert the magic_code+client mac in relay tag */
-						pMagic = (unsigned short *)tag->tag_data;
+						pMagic = (__be16 *)tag->tag_data;
 						*pMagic = htons(MAGIC_CODE);
 						memcpy(tag->tag_data+MAGIC_CODE_LEN, skb->data+ETH_ALEN, ETH_ALEN);
 
@@ -908,7 +908,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 						return -1;
 					}
 
-					pMagic = (unsigned short *)tag->tag_data;
+					pMagic = (__be16 *)tag->tag_data;
 					if (ntohs(*pMagic) != MAGIC_CODE) {
 						DEBUG_ERR("Can't find MAGIC_CODE in %s packet!\n",
 							(ph->code == PADO_CODE ? "PADO" : "PADS"));
@@ -1005,7 +1005,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 				iph->daddr.s6_addr16[4], iph->daddr.s6_addr16[5], iph->daddr.s6_addr16[6], iph->daddr.s6_addr16[7]);
 
 			if (memcmp(&iph->saddr, "\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0", 16)) {
-				__nat25_generate_ipv6_network_addr(networkAddr, (unsigned int *)&iph->saddr);
+				__nat25_generate_ipv6_network_addr(networkAddr, (__be32 *)&iph->saddr);
 				__nat25_db_network_insert(priv, skb->data+ETH_ALEN, networkAddr);
 				__nat25_db_print(priv);
 
@@ -1016,9 +1016,10 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 						struct icmp6hdr  *hdr = (struct icmp6hdr *)(skb->data + ETH_HLEN + sizeof(*iph));
 						hdr->icmp6_cksum = 0;
 						hdr->icmp6_cksum = csum_ipv6_magic(&iph->saddr, &iph->daddr,
-										iph->payload_len,
+										be16_to_cpu(iph->payload_len),
 										IPPROTO_ICMPV6,
-										csum_partial((__u8 *)hdr, iph->payload_len, 0));
+										csum_partial((__u8 *)hdr,
+										be16_to_cpu(iph->payload_len), 0));
 					}
 				}
 			}
@@ -1029,7 +1030,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff *skb, int method)
 				   iph->saddr.s6_addr16[4], iph->saddr.s6_addr16[5], iph->saddr.s6_addr16[6], iph->saddr.s6_addr16[7],
 				   iph->daddr.s6_addr16[0], iph->daddr.s6_addr16[1], iph->daddr.s6_addr16[2], iph->daddr.s6_addr16[3],
 				   iph->daddr.s6_addr16[4], iph->daddr.s6_addr16[5], iph->daddr.s6_addr16[6], iph->daddr.s6_addr16[7]);
-			__nat25_generate_ipv6_network_addr(networkAddr, (unsigned int *)&iph->daddr);
+			__nat25_generate_ipv6_network_addr(networkAddr, (__be32 *)&iph->daddr);
 			__nat25_db_network_lookup_and_replace(priv, skb, networkAddr);
 			return 0;
 		default:
@@ -1110,17 +1111,17 @@ struct dhcpMessage {
 	u_int8_t htype;
 	u_int8_t hlen;
 	u_int8_t hops;
-	u_int32_t xid;
-	u_int16_t secs;
-	u_int16_t flags;
-	u_int32_t ciaddr;
-	u_int32_t yiaddr;
-	u_int32_t siaddr;
-	u_int32_t giaddr;
+	__be32 xid;
+	__be16 secs;
+	__be16 flags;
+	__be32 ciaddr;
+	__be32 yiaddr;
+	__be32 siaddr;
+	__be32 giaddr;
 	u_int8_t chaddr[16];
 	u_int8_t sname[64];
 	u_int8_t file[128];
-	u_int32_t cookie;
+	__be32 cookie;
 	u_int8_t options[308]; /* 312 - cookie */
 };
 
-- 
1.8.4
