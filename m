From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 01/13] wimax/i2400m: reduce verbosity of debug messages in boot mode
Date: Wed,  4 Nov 2009 13:39:56 -0800
Message-ID: <e1633fd636f3ed0379fcf08c47962205eadddb6b.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45636 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932757AbZKDVmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:10 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missed a debug message that was being constantly printed as a
dev_err(); became annoying. Demote it to a debug message.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio-rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index 98ee7fd..8adf6c9 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -165,7 +165,7 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 		spin_unlock(&i2400m->rx_lock);
 		memcpy(i2400m->bm_ack_buf, skb->data, rx_size);
 		wake_up(&i2400ms->bm_wfa_wq);
-		dev_err(dev, "RX: SDIO boot mode message\n");
+		d_printf(5, dev, "RX: SDIO boot mode message\n");
 		kfree_skb(skb);
 		goto out;
 	}
-- 
1.6.2.5

