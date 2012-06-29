From: Vincent Sanders <vincent.sanders@collabora.co.uk>
Subject: [PATCH net-next 06/15] netfilter: Add NFPROTO_BUS hook constant for AF_BUS socket family
Date: Fri, 29 Jun 2012 17:45:45 +0100
Message-ID: <1340988354-26981-7-git-send-email-vincent.sanders@collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

AF_BUS sockets add a netfilter NF_HOOK() on the packet sending path.
This allows packet to be mangled by registered netfilter hooks.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 include/linux/netfilter.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index c613cf0..0698924 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -67,6 +67,7 @@ enum {
 	NFPROTO_BRIDGE =  7,
 	NFPROTO_IPV6   = 10,
 	NFPROTO_DECNET = 12,
+	NFPROTO_BUS,
 	NFPROTO_NUMPROTO,
 };
 
-- 
1.7.10
