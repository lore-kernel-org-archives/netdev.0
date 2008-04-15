From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 8/8][GRE]: Allow for IPPROTO_GRE protocol in namespaces.
Date: Tue, 15 Apr 2008 17:03:04 +0400
Message-ID: <4804A788.50208@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43892 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbYDOM2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:28:46 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one was also disabled by default for sanity.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7ff5262..2ada033 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1297,6 +1297,7 @@ static int ipgre_fb_tunnel_init(struct net_device *dev)
 static struct net_protocol ipgre_protocol = {
 	.handler	=	ipgre_rcv,
 	.err_handler	=	ipgre_err,
+	.netns_ok	=	1,
 };
 
 static void ipgre_destroy_tunnels(struct ipgre_net *ign)
-- 
1.5.3.4

