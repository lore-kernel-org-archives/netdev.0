From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] gtp: Rename jump labels in gtp_hashtable_new()
Date: Thu, 26 Jan 2017 11:22:16 +0100
Message-ID: <f87c0637-ca8f-63e9-ebe0-6d58b0ecc035@users.sourceforge.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 26 Jan 2017 10:54:20 +0100

Adjust a jump label according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/gtp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 2d4ddc000919..1571d6c7fe81 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -791,7 +791,7 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 	gtp->tid_hash = kmalloc_array(hsize, sizeof(*gtp->tid_hash),
 				      GFP_KERNEL);
 	if (!gtp->tid_hash)
-		goto err1;
+		goto free_hash;
 
 	gtp->hash_size = hsize;
 
@@ -800,7 +800,7 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 		INIT_HLIST_HEAD(&gtp->tid_hash[i]);
 	}
 	return 0;
-err1:
+free_hash:
 	kfree(gtp->addr_hash);
 	return -ENOMEM;
 }
-- 
2.11.0
