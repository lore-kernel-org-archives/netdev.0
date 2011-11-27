From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 28/62] vhost: remove the second argument of k[un]map_atomic()
Date: Sun, 27 Nov 2011 13:27:08 +0800
Message-ID: <1322371662-26166-29-git-send-email-amwang@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, Cong Wang <amwang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/vhost/vhost.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..bdb2d64 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -937,9 +937,9 @@ static int set_bit_to_user(int nr, void __user *addr)
 	if (r < 0)
 		return r;
 	BUG_ON(r != 1);
-	base = kmap_atomic(page, KM_USER0);
+	base = kmap_atomic(page);
 	set_bit(bit, base);
-	kunmap_atomic(base, KM_USER0);
+	kunmap_atomic(base);
 	set_page_dirty_lock(page);
 	put_page(page);
 	return 0;
-- 
1.7.4.4
