From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 09/12] vxlan: port module param should be ushort
Date: Mon, 10 Jun 2013 13:24:42 -0700
Message-ID: <20130610132442.37ee2b57@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:60116 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab3FJUZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:50 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so7788253pdi.39
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:50 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP ports are limited to 16 bits.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-06-10 12:20:02.174061866 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:03.034052087 -0700
@@ -70,8 +70,8 @@ struct vxlanhdr {
  * The IANA assigned port is 4789, but the Linux default is 8472
  * for compatability with early adopters.
  */
-static unsigned int vxlan_port __read_mostly = 8472;
-module_param_named(udp_port, vxlan_port, uint, 0444);
+static unsigned short vxlan_port __read_mostly = 8472;
+module_param_named(udp_port, vxlan_port, ushort, 0444);
 MODULE_PARM_DESC(udp_port, "Destination UDP port");
 
 static bool log_ecn_error = true;
