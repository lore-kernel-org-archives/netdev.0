From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 7/10][TUNNELS]: Remove stat member from ip_tunnel
 struct.
Date: Tue, 20 May 2008 20:39:51 +0400
Message-ID: <4832FED7.1000709@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45647 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757829AbYETQmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:42:17 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users already use on-device statistics, so this field can be
safely removed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/ipip.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 633ed4d..a85bda6 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -11,7 +11,6 @@ struct ip_tunnel
 {
 	struct ip_tunnel	*next;
 	struct net_device	*dev;
-	struct net_device_stats	stat;
 
 	int			recursion;	/* Depth of hard_start_xmit recursion */
 	int			err_count;	/* Number of arrived ICMP errors */
-- 
1.5.3.4

