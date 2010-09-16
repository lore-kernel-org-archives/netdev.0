From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] ethtool: Add comments for valid use of
 flow types
Date: Thu, 16 Sep 2010 22:34:26 +0100
Message-ID: <1284672866.2283.40.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21541 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986Ab0IPVe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 17:34:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 00334ee..b67af60 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -841,21 +841,21 @@ struct ethtool_ops {
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
 /* L3-L4 network traffic flow types */
-#define	TCP_V4_FLOW	0x01
-#define	UDP_V4_FLOW	0x02
-#define	SCTP_V4_FLOW	0x03
-#define	AH_ESP_V4_FLOW	0x04
-#define	TCP_V6_FLOW	0x05
-#define	UDP_V6_FLOW	0x06
-#define	SCTP_V6_FLOW	0x07
-#define	AH_ESP_V6_FLOW	0x08
-#define	AH_V4_FLOW	0x09
-#define	ESP_V4_FLOW	0x0a
-#define	AH_V6_FLOW	0x0b
-#define	ESP_V6_FLOW	0x0c
-#define	IP_USER_FLOW	0x0d
-#define	IPV4_FLOW	0x10
-#define	IPV6_FLOW	0x11
+#define	TCP_V4_FLOW	0x01	/* hash or spec (tcp_ip4_spec) */
+#define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
+#define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
+#define	AH_ESP_V4_FLOW	0x04	/* hash only */
+#define	TCP_V6_FLOW	0x05	/* hash only */
+#define	UDP_V6_FLOW	0x06	/* hash only */
+#define	SCTP_V6_FLOW	0x07	/* hash only */
+#define	AH_ESP_V6_FLOW	0x08	/* hash only */
+#define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
+#define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
+#define	AH_V6_FLOW	0x0b	/* hash only */
+#define	ESP_V6_FLOW	0x0c	/* hash only */
+#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	IPV4_FLOW	0x10	/* hash only */
+#define	IPV6_FLOW	0x11	/* hash only */
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

