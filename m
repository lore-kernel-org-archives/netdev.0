From: Patrick McHardy <kaber@trash.net>
Subject: [DECNET]: Use correct config option for routing by fwmark in compare_keys()
Date: Thu, 12 Oct 2006 12:23:37 +0200
Message-ID: <452E17A9.2080208@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020604040300010605070204"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60654 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030703AbWJLKWM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 06:22:12 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020604040300010605070204
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Small bugfix to the compare_keys fix.


--------------020604040300010605070204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[DECNET]: Use correct config option for routing by fwmark in compare_keys()

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8302c73a668852de1b1527038bc4c432cf757a7f
tree d4e9be4f4bfc87b56bf4756a12a2538f2211fc84
parent 22c4cae48af19e83f31bb88a98970166beacc4fd
author Patrick McHardy <kaber@trash.net> Thu, 12 Oct 2006 12:22:57 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Oct 2006 12:22:57 +0200

 net/decnet/dn_route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a2a43d8..491429c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -269,7 +269,7 @@ static inline int compare_keys(struct fl
 {
 	return ((fl1->nl_u.dn_u.daddr ^ fl2->nl_u.dn_u.daddr) |
 		(fl1->nl_u.dn_u.saddr ^ fl2->nl_u.dn_u.saddr) |
-#ifdef CONFIG_IP_ROUTE_FWMARK
+#ifdef CONFIG_DECNET_ROUTE_FWMARK
 		(fl1->nl_u.dn_u.fwmark ^ fl2->nl_u.dn_u.fwmark) |
 #endif
 		(fl1->nl_u.dn_u.scope ^ fl2->nl_u.dn_u.scope) |

--------------020604040300010605070204--
