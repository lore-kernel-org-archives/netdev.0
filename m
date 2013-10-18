From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 9/9 RESENT] staging: r8188eu: Fix sparse warnings in rtw_br_ext.c
Date: Fri, 18 Oct 2013 16:38:26 -0500
Message-ID: <5261AA52.1070307@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	devel@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:64949 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218Ab3JRVi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:38:28 -0400
Received: by mail-oa0-f45.google.com with SMTP id i4so3171015oah.4
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:38:27 -0700 (PDT)
In-Reply-To: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse has the following warnings for core/rtw_br_ext.c

   CHECK   drivers/staging/rtl8188eu/core/rtw_br_ext.c
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:101: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:101:    expected unsigned int 
*ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:101:    got restricted __be32 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:123: warning: incorrect type in 
argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:123:    expected unsigned short 
*ipxSocketAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:705:123:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:710:99: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:710:99:    expected unsigned int 
*ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:710:99:    got restricted __be32 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:101: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:101:    expected unsigned int 
*ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:101:    got restricted __be32 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:121: warning: incorrect type in 
argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:121:    expected unsigned short 
*ipxSocketAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:719:121:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:726:99: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:726:99:    expected unsigned int 
*ipxNetAddr
drivers/staging/rtl8188eu/core/rtw_br_ext.c:726:99:    got restricted __be32 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:754:83: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:754:83:    expected unsigned short 
*network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:754:83:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:767:83: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:767:83:    expected unsigned short 
*network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:767:83:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:788:83: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:788:83:    expected unsigned short 
*network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:788:83:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:800:83: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:800:83:    expected unsigned short 
*network
drivers/staging/rtl8188eu/core/rtw_br_ext.c:800:83:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:854:57: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:854:57:    expected unsigned short 
[unsigned] [short] <noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:854:57:    got restricted __be16 
[usertype] <noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:92:23: warning: restricted __be16 
degrades to integer
drivers/staging/rtl8188eu/core/rtw_br_ext.c:881:95: warning: incorrect type in 
argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:881:95:    expected unsigned short *sid
drivers/staging/rtl8188eu/core/rtw_br_ext.c:881:95:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:917:45: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:917:45: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:917:45: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:917:45: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:949:112: warning: incorrect type in 
argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:949:112:    expected unsigned short *sid
drivers/staging/rtl8188eu/core/rtw_br_ext.c:949:112:    got restricted __be16 
*<noident>
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1024:84: warning: incorrect type in 
argument 3 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1024:84:    expected unsigned int 
[unsigned] [usertype] len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1024:84:    got restricted __be16 
[usertype] payload_len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1026:110: warning: incorrect type in 
argument 2 (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1026:110:    expected int [signed] len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1026:110:    got restricted __be16 
[usertype] payload_len
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1151:54: warning: cast to restricted 
__be32
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1154:70: warning: restricted __be16 
degrades to integer
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:70: warning: invalid assignment: |=
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:70:    left side has type 
unsigned short
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:70:    right side has type 
restricted __be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1162:63: warning: restricted __sum16 
degrades to integer
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1163:64: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1163:64: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1163:64: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1163:64: warning: cast to restricted 
__be16
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1166:69: warning: incorrect type in 
assignment (different base types)
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1166:69:    expected restricted 
__sum16 [usertype] check
drivers/staging/rtl8188eu/core/rtw_br_ext.c:1166:69:    got int

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/core/rtw_br_ext.c | 52 +++++++++++++++++------------
  1 file changed, 31 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_br_ext.c 
b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
index 9f40742..d50fc13 100644
--- a/drivers/staging/rtl8188eu/core/rtw_br_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
@@ -89,7 +89,7 @@ static inline int __nat25_add_pppoe_tag(struct sk_buff *skb, 
struct pppoe_tag *t
  	struct pppoe_hdr *ph = (struct pppoe_hdr *)(skb->data + ETH_HLEN);
  	int data_len;
  -	data_len = tag->tag_len + TAG_HDR_LEN;
+	data_len = be16_to_cpu(tag->tag_len) + TAG_HDR_LEN;
  	if (skb_tailroom(skb) < data_len) {
  		_DEBUG_ERR("skb_tailroom() failed in add SID tag!\n");
  		return -1;
@@ -155,44 +155,53 @@ static inline void 
__nat25_generate_ipv4_network_addr(unsigned char *networkAddr
    static inline void __nat25_generate_ipx_network_addr_with_node(unsigned char 
*networkAddr,
-				unsigned int *ipxNetAddr, unsigned char *ipxNodeAddr)
+				__be32 *ipxNetAddr, unsigned char *ipxNodeAddr)
  {
+	u32 cpu_netaddr = be32_to_cpu(*ipxNetAddr);
+
  	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
   	networkAddr[0] = NAT25_IPX;
-	memcpy(networkAddr+1, (unsigned char *)ipxNetAddr, 4);
+	memcpy(networkAddr+1, &cpu_netaddr, 4);
  	memcpy(networkAddr+5, ipxNodeAddr, 6);
  }
    static inline void __nat25_generate_ipx_network_addr_with_socket(unsigned 
char *networkAddr,
-				unsigned int *ipxNetAddr, unsigned short *ipxSocketAddr)
+				__be32 *ipxNetAddr, __be16 *ipxSocketAddr)
  {
+	u32 cpu_netaddr = be32_to_cpu(*ipxNetAddr);
+	u16 cpu_sockaddr = be16_to_cpu(*ipxSocketAddr);
+
  	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
   	networkAddr[0] = NAT25_IPX;
-	memcpy(networkAddr+1, (unsigned char *)ipxNetAddr, 4);
-	memcpy(networkAddr+5, (unsigned char *)ipxSocketAddr, 2);
+	memcpy(networkAddr+1, &cpu_netaddr, 4);
+	memcpy(networkAddr+5, &cpu_sockaddr, 2);
  }
    static inline void __nat25_generate_apple_network_addr(unsigned char 
*networkAddr,
-				unsigned short *network, unsigned char *node)
+				__be16 *network, unsigned char *node)
  {
+	u16 cpu_net = be16_to_cpu(*network);
+
  	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
   	networkAddr[0] = NAT25_APPLE;
-	memcpy(networkAddr+1, (unsigned char *)network, 2);
+	memcpy(networkAddr+1, &cpu_net, 2);
  	networkAddr[3] = *node;
  }
   static inline void __nat25_generate_pppoe_network_addr(unsigned char 
*networkAddr,
-				unsigned char *ac_mac, unsigned short *sid)
+				unsigned char *ac_mac, __be16 *sid)
  {
+	u16 cpu_sid = be16_to_cpu(*sid);
+
  	memset(networkAddr, 0, MAX_NETWORK_ADDR_LEN);
   	networkAddr[0] = NAT25_PPPOE;
-	memcpy(networkAddr+1, (unsigned char *)sid, 2);
+	memcpy(networkAddr+1, &cpu_sid, 2);
  	memcpy(networkAddr+3, (unsigned char *)ac_mac, 6);
  }
  @@ -811,7 +820,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff 
*skb, int method)
  		/*                Handle PPPoE frame                 */
  		/*---------------------------------------------------*/
  		struct pppoe_hdr *ph = (struct pppoe_hdr *)(skb->data + ETH_HLEN);
-		unsigned short *pMagic;
+		__be16 *pMagic;
   		switch (method) {
  		case NAT25_CHECK:
@@ -849,7 +858,7 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff 
*skb, int method)
  						tag->tag_len = htons(MAGIC_CODE_LEN+RTL_RELAY_TAG_LEN+old_tag_len);
   						/*  insert the magic_code+client mac in relay tag */
-						pMagic = (unsigned short *)tag->tag_data;
+						pMagic = (__be16  *)tag->tag_data;
  						*pMagic = htons(MAGIC_CODE);
  						memcpy(tag->tag_data+MAGIC_CODE_LEN, skb->data+ETH_ALEN, ETH_ALEN);
  @@ -912,8 +921,8 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff 
*skb, int method)
  						return -1;
  					}
  -					pMagic = (unsigned short *)tag->tag_data;
-					if (ntohs(*pMagic) != MAGIC_CODE) {
+					pMagic = (__be16 *)tag->tag_data;
+					if (be16_to_cpu(*pMagic) != MAGIC_CODE) {
  						DEBUG_ERR("Can't find MAGIC_CODE in %s packet!\n",
  							(ph->code == PADO_CODE ? "PADO" : "PADS"));
  						return -1;
@@ -1018,11 +1027,12 @@ int nat25_db_handle(struct adapter *priv, struct sk_buff 
*skb, int method)
  					if (update_nd_link_layer_addr(skb->data + ETH_HLEN + sizeof(*iph),
  								      skb->len - ETH_HLEN - sizeof(*iph), GET_MY_HWADDR(priv))) {
  						struct icmp6hdr  *hdr = (struct icmp6hdr *)(skb->data + ETH_HLEN + 
sizeof(*iph));
+						u32 len = __be16_to_cpu(iph->payload_len);
  						hdr->icmp6_cksum = 0;
  						hdr->icmp6_cksum = csum_ipv6_magic(&iph->saddr, &iph->daddr,
-										iph->payload_len,
+										len,
  										IPPROTO_ICMPV6,
-										csum_partial((__u8 *)hdr, iph->payload_len, 0));
+										csum_partial((__u8 *)hdr, len, 0));
  					}
  				}
  			}
@@ -1117,7 +1127,7 @@ struct dhcpMessage {
  	u_int8_t hops;
  	u_int32_t xid;
  	u_int16_t secs;
-	u_int16_t flags;
+	__be16 flags;
  	u_int32_t ciaddr;
  	u_int32_t yiaddr;
  	u_int32_t siaddr;
@@ -1125,7 +1135,7 @@ struct dhcpMessage {
  	u_int8_t chaddr[16];
  	u_int8_t sname[64];
  	u_int8_t file[128];
-	u_int32_t cookie;
+	__be32 cookie;
  	u_int8_t options[308]; /* 312 - cookie */
  };
  @@ -1152,17 +1162,17 @@ void dhcp_flag_bcast(struct adapter *priv, struct 
sk_buff *skb)
  					if (cookie == DHCP_MAGIC) { /*  match magic word */
  						if (!(dhcph->flags & htons(BROADCAST_FLAG))) {
  							/*  if not broadcast */
-							register int sum = 0;
+							register int sum;
   							DEBUG_INFO("DHCP: change flag of DHCP request to broadcast.\n");
  							/*  or BROADCAST flag */
  							dhcph->flags |= htons(BROADCAST_FLAG);
  							/*  recalculate checksum */
-							sum = ~(udph->check) & 0xffff;
+							sum = (__force int)(~(udph->check)) & 0xffff;
  							sum += be16_to_cpu(dhcph->flags);
  							while (sum >> 16)
  								sum = (sum & 0xffff) + (sum >> 16);
-							udph->check = ~sum;
+							udph->check = (__force __sum16)~sum;
  						}
  					}
  				}
-- 
1.8.4
