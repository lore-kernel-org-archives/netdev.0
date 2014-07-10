From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 14/33] net: caif_serial - set name assign type
Date: Thu, 10 Jul 2014 10:17:19 +0200
Message-ID: <1404980258-30853-15-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name is uniquely determined by the name of the TTY.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
---
 drivers/net/caif/caif_serial.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 27bbc56..4432462 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -349,7 +349,7 @@ static int ldisc_open(struct tty_struct *tty)
 	result = snprintf(name, sizeof(name), "cf%s", tty->name);
 	if (result >= IFNAMSIZ)
 		return -EINVAL;
-	dev = alloc_netdev(sizeof(*ser), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*ser), name, NET_NAME_PREDICTABLE,
 			   caifdev_setup);
 	if (!dev)
 		return -ENOMEM;
-- 
1.9.3
