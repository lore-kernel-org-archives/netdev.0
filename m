From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net/rose: Delete an error message for a failed memory
 allocation in rose_proto_init()
Date: Sat, 14 Oct 2017 21:06:55 +0200
Message-ID: <0b86508a-ed7a-0b6c-5797-f4aaedba46bf@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?Q?Ralf_B=c3=a4chle?= <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 14 Oct 2017 20:57:28 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/rose/af_rose.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4a9729257023..ce37be0027ca 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1529,7 +1529,6 @@ static int __init rose_proto_init(void)
 
 	dev_rose = kzalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
-		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		rc = -ENOMEM;
 		goto out_proto_unregister;
 	}
-- 
2.14.2
