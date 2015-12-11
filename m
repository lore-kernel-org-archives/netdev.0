From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] ppp: declare ppp devices as enumerated
 interfaces
Date: Fri, 11 Dec 2015 19:54:52 +0100
Message-ID: <14571df502f861b2a5668017bccca138253f4e67.1449859708.git.g.nault@alphalink.fr>
References: <cover.1449859708.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38915 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbbLKTAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 14:00:04 -0500
Content-Disposition: inline
In-Reply-To: <cover.1449859708.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let user space be aware of the naming scheme used by ppp interfaces
(visible in /sys/class/net/<iface>/name_assign_type).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 1cd7651..fc8ad00 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2726,8 +2726,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
 	int ret = -ENOMEM;
 	int i;
 
-	dev = alloc_netdev(sizeof(struct ppp), "", NET_NAME_UNKNOWN,
-			   ppp_setup);
+	dev = alloc_netdev(sizeof(struct ppp), "", NET_NAME_ENUM, ppp_setup);
 	if (!dev)
 		goto out1;
 
-- 
2.6.4
