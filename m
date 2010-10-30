From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/39] drivers/net/usb: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:34 -0700
Message-ID: <4ef13c27899febe0cef4f1633321ddedbe97cfcf.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing newlines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/ipheth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index b2bcf99..7d42f9a 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -363,7 +363,7 @@ static int ipheth_tx(struct sk_buff *skb, struct net_device *net)
 
 	/* Paranoid */
 	if (skb->len > IPHETH_BUF_SIZE) {
-		WARN(1, "%s: skb too large: %d bytes", __func__, skb->len);
+		WARN(1, "%s: skb too large: %d bytes\n", __func__, skb->len);
 		dev->net->stats.tx_dropped++;
 		dev_kfree_skb_irq(skb);
 		return NETDEV_TX_OK;
-- 
1.7.3.1.g432b3.dirty
