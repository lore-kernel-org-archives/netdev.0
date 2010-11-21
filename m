From: Joe Perches <joe@perches.com>
Subject: [PATCH 33/62] ni65: Use static const
Date: Sat, 20 Nov 2010 18:38:34 -0800
Message-ID: <af8e14326a7f1657e3c7180f0c7b0ae5d5da5afe.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  13234	    187	   3488	  16909	   420d	drivers/net/ni65.o.old
  13254	    167	   3488	  16909	   420d	drivers/net/ni65.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ni65.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index da228a0..c75ae85 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -361,8 +361,8 @@ static int dma;
 struct net_device * __init ni65_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(0);
-	static int ports[] = {0x360,0x300,0x320,0x340, 0};
-	int *port;
+	static const int ports[] = { 0x360, 0x300, 0x320, 0x340, 0 };
+	const int *port;
 	int err = 0;
 
 	if (!dev)
-- 
1.7.3.2.245.g03276.dirty
