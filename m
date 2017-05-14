From: Maciek Fijalkowski <macfij7@wp.pl>
Subject: [PATCH 1/3] Fix ERROR: trailing statements should be on next line
Date: Sun, 14 May 2017 19:51:28 +0200
Message-ID: <20170514175130.18664-1-macfij7@wp.pl>
Cc: jasonwang@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Maciej Fijalkowski <macfij7@wp.pl>
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maciej Fijalkowski <macfij7@wp.pl>

Signed-off-by: Maciej Fijalkowski <macfij7@wp.pl>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9320d96..f20dfb8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -217,7 +217,8 @@ static void give_pages(struct receive_queue *rq, struct page *page)
 	struct page *end;
 
 	/* Find end of list, sew whole thing into vi->rq.pages. */
-	for (end = page; end->private; end = (struct page *)end->private);
+	for (end = page; end->private; end = (struct page *)end->private)
+		;
 	end->private = (unsigned long)rq->pages;
 	rq->pages = page;
 }
-- 
2.4.11
