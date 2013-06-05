From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 07/10] vxlan: port module param should be ushort
Date: Tue,  4 Jun 2013 21:24:11 -0700
Message-ID: <1370406254-6341-7-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:45875 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab3FEEY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:29 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so1212512pbb.36
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:28 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP ports's are limited to 16 bits.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 593c895..57b5274 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
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
-- 
1.7.10.4
