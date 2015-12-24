From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V5 1/9] Drivers: hv: vmbus: add a helper function to set a channel's pending send size
Date: Thu, 24 Dec 2015 06:13:57 -0800
Message-ID: <1450966437-13076-1-git-send-email-decui@microsoft.com>
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
index 753dbad..e4867a7 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -790,6 +790,12 @@ static inline void *get_per_channel_state(struct vmbus_channel *c)
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
2.1.4
