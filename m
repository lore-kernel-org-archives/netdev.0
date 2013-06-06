From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 3/8] macvlan: switch to use IS_ENABLED()
Date: Thu,  6 Jun 2013 17:54:35 +0800
Message-ID: <1370512480-14272-4-git-send-email-jasowang@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/if_macvlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 84dde1d..e47ad46 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -8,7 +8,7 @@
 #include <net/netlink.h>
 #include <linux/u64_stats_sync.h>
 
-#if defined(CONFIG_MACVTAP) || defined(CONFIG_MACVTAP_MODULE)
+#if IS_ENABLED(CONFIG_MACVTAP)
 struct socket *macvtap_get_socket(struct file *);
 #else
 #include <linux/err.h>
-- 
1.7.1
