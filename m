From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] net: document accel_priv parameter for __dev_queue_xmit()
Date: Mon, 20 Jan 2014 11:25:13 +0800
Message-ID: <1390188313-9275-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51508 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaATDZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 22:25:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To silent "make htmldocs" warning.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/dev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0ce469e..d78dc62 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2781,8 +2781,9 @@ int dev_loopback_xmit(struct sk_buff *skb)
 EXPORT_SYMBOL(dev_loopback_xmit);
 
 /**
- *	dev_queue_xmit - transmit a buffer
+ *	__dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
+ *	@accel_priv: private data used for L2 forwarding offload
  *
  *	Queue a buffer for transmission to a network device. The caller must
  *	have set the device and priority and built the buffer before calling
-- 
1.8.3.2
