From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V4 5/7] Drivers: hv: vmbus: add a helper function to set a channel's pending send size
Date: Tue, 28 Jul 2015 05:35:17 -0700
Message-ID: <1438086917-19417-1-git-send-email-decui@microsoft.com>
Cc: pebolle@tiscali.nl, stefanha@redhat.com, vkuznets@redhat.com,
	dan.carpenter@oracle.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will be used by the coming net/hvsock driver.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 include/linux/hyperv.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index fda9790..47c5c1a 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -791,6 +791,12 @@ static inline void *get_per_channel_state(struct vmbus_channel *c)
 	return c->per_channel_state;
 }
 
+static inline void set_channel_pending_send_size(struct vmbus_channel *c,
+						 u32 size)
+{
+	c->outbound.ring_buffer->pending_send_sz = size;
+}
+
 void vmbus_onmessage(void *context);
 
 int vmbus_request_offers(void);
-- 
2.1.0
