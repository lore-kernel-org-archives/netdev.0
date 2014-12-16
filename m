From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 5/5] if_tun: drop broken IFF_VNET_LE
Date: Tue, 16 Dec 2014 15:05:23 +0200
Message-ID: <1418732988-3535-6-git-send-email-mst@redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	linux-api@vger.kernel.org, Jason Wang <jasowang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Everyone should use TUNSETVNETLE/TUNGETVNETLE instead.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/uapi/linux/if_tun.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 274630c..50ae243 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -59,7 +59,6 @@
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
-#define IFF_VNET_LE	0x10000
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
-- 
MST
