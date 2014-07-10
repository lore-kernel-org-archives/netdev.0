From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 32/33] net: x25_asy - set name assign type
Date: Thu, 10 Jul 2014 10:17:37 +0200
Message-ID: <1404980258-30853-33-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Names are given by the first available X.25 channel, so order
of device creation matters.

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/net/wan/x25_asy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index df6c073..2821f8b 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -81,8 +81,8 @@ static struct x25_asy *x25_asy_alloc(void)
 		char name[IFNAMSIZ];
 		sprintf(name, "x25asy%d", i);
 
-		dev = alloc_netdev(sizeof(struct x25_asy), name,
-				   NET_NAME_UNKNOWN, x25_asy_setup);
+		dev = alloc_netdev(sizeof(struct x25_asy),
+				   name, NET_NAME_ENUM, x25_asy_setup);
 		if (!dev)
 			return NULL;
 
-- 
1.9.3
