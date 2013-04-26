From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vxlan: use IANA assigned port
Date: Fri, 26 Apr 2013 16:33:46 -0700
Message-ID: <20130426163346.762c41c1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kenneth Duda <kduda@aristanetworks.com>,
	Chris Wright <chrisw@sous-sol.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:43787 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab3DZXdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 19:33:53 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so156407dad.18
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 16:33:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ken Duda of Arista Networks, one of the VXLAN RFC authors notified
me that IANA has assigned an official port for VXLAN. My initial version
of the driver used the value from CISCO LISP that was also being used by
OpenVswitch.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-04-22 15:44:00.962002827 -0700
+++ b/drivers/net/vxlan.c	2013-04-26 16:29:19.349507680 -0700
@@ -8,7 +8,6 @@
  * published by the Free Software Foundation.
  *
  * TODO
- *  - use IANA UDP port number (when defined)
  *  - IPv6 (not in RFC)
  */
 
@@ -66,7 +65,7 @@ struct vxlanhdr {
 };
 
 /* UDP port for VXLAN traffic. */
-static unsigned int vxlan_port __read_mostly = 8472;
+static unsigned int vxlan_port __read_mostly = 4789;
 module_param_named(udp_port, vxlan_port, uint, 0444);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
 
