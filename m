From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix IPv4 tunnel mode decapsulation with IPV6=n
Date: Tue, 13 Feb 2007 01:16:02 +0100
Message-ID: <45D10342.3030903@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040702080405050501010309"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54292 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030528AbXBMAQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 19:16:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040702080405050501010309
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------040702080405050501010309
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix IPv4 tunnel mode decapsulation with IPV6=n

Add missing break when CONFIG_IPV6=n.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 651521586d5f08c5d6d7198ceef1555b93135b6a
tree 5ee1183f4bc1f49f467b5bdcfebf1c5181bffcd7
parent 6ec183b20c4a1c0eafd541444ae11f8e5779d153
author Patrick McHardy <kaber@trash.net> Tue, 13 Feb 2007 01:14:35 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 13 Feb 2007 01:14:35 +0100

 net/ipv4/xfrm4_mode_tunnel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index e54c549..e1cab33 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -95,6 +95,7 @@ static int xfrm4_tunnel_input(struct xfr
 
 	switch(iph->protocol){
 		case IPPROTO_IPIP:
+			break;
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 		case IPPROTO_IPV6:
 			break;

--------------040702080405050501010309--
