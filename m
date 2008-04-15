From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 8/8][SIT]: Allow for IPPROTO_IPV6 protocol in namespaces.
Date: Tue, 15 Apr 2008 17:39:42 +0400
Message-ID: <4804B01E.3010406@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56025 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbYDONFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:05:23 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sit-generated traffic enter the namespace.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/tunnel4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index cc4cd0e..d3b709a 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -144,6 +144,7 @@ static struct net_protocol tunnel64_protocol = {
 	.handler	=	tunnel64_rcv,
 	.err_handler	=	tunnel64_err,
 	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 #endif
 
-- 
1.5.3.4

