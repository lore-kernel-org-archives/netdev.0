From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] tun: Rename a jump label in update_filter()
Date: Sat, 20 Aug 2016 09:37:16 +0200
Message-ID: <0c8d93e2-34cf-ca23-955e-999f424b3ab2@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 09:00:34 +0200

Adjust a jump target according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/tun.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a1aeccb..e249428 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -753,7 +753,7 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 	for (; n < uf.count; n++) {
 		if (!is_multicast_ether_addr(addr[n].u)) {
 			err = 0; /* no filter */
-			goto done;
+			goto free_addr;
 		}
 		addr_hash_set(filter->mask, addr[n].u);
 	}
@@ -769,8 +769,7 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 
 	/* Return the number of exact filters */
 	err = nexact;
-
-done:
+free_addr:
 	kfree(addr);
 	return err;
 }
-- 
2.9.3

