From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 33/33] net: slip - set name assign type
Date: Thu, 10 Jul 2014 10:17:38 +0200
Message-ID: <1404980258-30853-34-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Tyler Hall <tylerwhall@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Names are given by the first available SLIP channel, so order
of device creation matters.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Tyler Hall <tylerwhall@gmail.com>
---
 drivers/net/slip/slip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 05387b1..2a305d1 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -749,7 +749,7 @@ static struct slip *sl_alloc(dev_t line)
 		return NULL;
 
 	sprintf(name, "sl%d", i);
-	dev = alloc_netdev(sizeof(*sl), name, NET_NAME_UNKNOWN, sl_setup);
+	dev = alloc_netdev(sizeof(*sl), name, NET_NAME_ENUM, sl_setup);
 	if (!dev)
 		return NULL;
 
-- 
1.9.3
