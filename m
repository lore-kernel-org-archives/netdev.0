From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/6] vxlan: document UDP default port
Date: Sat, 27 Apr 2013 14:31:53 -0700
Message-ID: <20130427213258.207552537@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52170 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753811Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-port-comprimise.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default port for VXLAN is not same as IANA value.
Document this.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-04-27 13:38:54.124378801 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 13:38:57.232338603 -0700
@@ -8,7 +8,6 @@
  * published by the Free Software Foundation.
  *
  * TODO
- *  - use IANA UDP port number (when defined)
  *  - IPv6 (not in RFC)
  */
 
@@ -65,7 +64,10 @@ struct vxlanhdr {
 	__be32 vx_vni;
 };
 
-/* UDP port for VXLAN traffic. */
+/* UDP port for VXLAN traffic.
+ * The IANA assigned port is 4789, but the Linux default is 8472
+ * for compatability with early adopters.
+ */
 static unsigned int vxlan_port __read_mostly = 8472;
 module_param_named(udp_port, vxlan_port, uint, 0444);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
