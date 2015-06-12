From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH net-next] Increase limit of macvtap queues
Date: Fri, 12 Jun 2015 19:00:28 +0530
Message-ID: <1434115828-9461-1-git-send-email-pagupta@redhat.com>
Cc: kaber@trash.net, mst@redhat.com, davem@davemloft.net,
	jasowang@redhat.com, vyasevic@redhat.com,
	bhutchings@solarflare.com, therbert@google.com,
	viro@zeniv.linux.org.uk, pagupta@redhat.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macvtap should be compatible with tuntap for maximum number
of queues. '1059590254fa9dce9cafc4f07d1103dbec415e76' removes
the limitation and increases number of queues in tuntap.
Now, Its safe to increase number of queues in Macvtap as well.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 include/linux/if_macvlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 6f6929e..a4ccc31 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -29,7 +29,7 @@ struct macvtap_queue;
  * Maximum times a macvtap device can be opened. This can be used to
  * configure the number of receive queue, e.g. for multiqueue virtio.
  */
-#define MAX_MACVTAP_QUEUES     16
+#define MAX_MACVTAP_QUEUES     256

 #define MACVLAN_MC_FILTER_BITS 8
 #define MACVLAN_MC_FILTER_SZ   (1 << MACVLAN_MC_FILTER_BITS)
--
1.7.1
