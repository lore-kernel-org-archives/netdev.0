From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/6] cxgb4vf: Use seq_putc() in mboxlog_show()
Date: Thu, 4 May 2017 22:31:13 +0200
Message-ID: <210c924f-3e13-10ec-9f6e-b63003798240@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 20:02:04 +0200

A single character (line break) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index ac7a150c54e9..4ac9316f3081 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1818,7 +1818,7 @@ static int mboxlog_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq, "  %08x %08x", hi, lo);
 	}
-	seq_puts(seq, "\n");
+	seq_putc(seq, '\n');
 	return 0;
 }
 
-- 
2.12.2
