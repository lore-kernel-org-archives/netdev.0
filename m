From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 5/6] sfc: update mcdi_pcol definitions for
 MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS
Date: Wed, 8 Feb 2017 16:51:50 +0000
Message-ID: <0a697ad5-6126-2dba-b967-cb59af96d854@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:34775 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751654AbdBHQze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:55:34 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 35cc3d4..47ced8a 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -11913,6 +11913,27 @@
 #define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_RESETTING_LBN 0
 #define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_RESETTING_WIDTH 1
 
+/* TUNNEL_ENCAP_UDP_PORT_ENTRY structuredef */
+#define    TUNNEL_ENCAP_UDP_PORT_ENTRY_LEN 4
+/* UDP port (the standard ports are named below but any port may be used) */
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_UDP_PORT_OFST 0
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_UDP_PORT_LEN 2
+/* enum: the IANA allocated UDP port for VXLAN */
+#define          TUNNEL_ENCAP_UDP_PORT_ENTRY_IANA_VXLAN_UDP_PORT  0x12b5
+/* enum: the IANA allocated UDP port for Geneve */
+#define          TUNNEL_ENCAP_UDP_PORT_ENTRY_IANA_GENEVE_UDP_PORT  0x17c1
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_UDP_PORT_LBN 0
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_UDP_PORT_WIDTH 16
+/* tunnel encapsulation protocol (only those named below are supported) */
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_PROTOCOL_OFST 2
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_PROTOCOL_LEN 2
+/* enum: VXLAN */
+#define          TUNNEL_ENCAP_UDP_PORT_ENTRY_VXLAN  0x0
+/* enum: Geneve */
+#define          TUNNEL_ENCAP_UDP_PORT_ENTRY_GENEVE  0x1
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_PROTOCOL_LBN 16
+#define       TUNNEL_ENCAP_UDP_PORT_ENTRY_PROTOCOL_WIDTH 16
+
 
 /***********************************/
 /* MC_CMD_RX_BALANCING
