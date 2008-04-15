From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 8/8][IPIP]: Allow for IPPROTO_IPIP protocol in
 namespaces.
Date: Tue, 15 Apr 2008 16:41:36 +0400
Message-ID: <4804A280.5040707@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45433 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625AbYDOMHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:07:16 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one was disabled by default for sanity.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/tunnel4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 978b3fd..cc4cd0e 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -136,6 +136,7 @@ static struct net_protocol tunnel4_protocol = {
 	.handler	=	tunnel4_rcv,
 	.err_handler	=	tunnel4_err,
 	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-- 
1.5.3.4

