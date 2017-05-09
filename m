From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/4] hamradio: Use seq_puts() in bpq_seq_show()
Date: Tue, 9 May 2017 16:24:18 +0200
Message-ID: <ef61af8b-a3b1-9d74-22e4-1df1bac08f98@users.sourceforge.net>
References: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Content-Language: en-US
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 15:45:09 +0200

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/hamradio/bpqether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index f62e7f325cf9..eaa0f2e8e561 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -434,7 +434,7 @@ static int bpq_seq_show(struct seq_file *seq, void *v)
 			bpqdev->dest_addr);
 
 		if (is_multicast_ether_addr(bpqdev->acpt_addr))
-			seq_printf(seq, "*\n");
+			seq_puts(seq, "*\n");
 		else
 			seq_printf(seq, "%pM\n", bpqdev->acpt_addr);
 
-- 
2.12.2

