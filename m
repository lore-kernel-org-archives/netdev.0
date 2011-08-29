From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/24] rose: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:35 -0700
Message-ID: <719ff1b5a486b1d2cf7820d09e29fe60bafc023d.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rose/af_rose.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index f9ea925..63ab96b 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1537,7 +1537,6 @@ static int __init rose_proto_init(void)
 
 	dev_rose = kzalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
-		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		rc = -ENOMEM;
 		goto out_proto_unregister;
 	}
-- 
1.7.6.405.gc1be0
