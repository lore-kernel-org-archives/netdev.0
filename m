From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] net/atm: Use seq_putc() in mpc_show()
Date: Tue, 2 May 2017 19:48:18 +0200
Message-ID: <e445e058-15cd-787c-0717-efd7faed999a@users.sourceforge.net>
References: <d9577c1f-07d1-b43a-df16-8626acfb1043@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d9577c1f-07d1-b43a-df16-8626acfb1043@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 2 May 2017 18:58:08 +0200

Single characters (line breaks) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/mpoa_proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 6ea6028fd865..324c4f95f4bf 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -161,7 +161,7 @@ static int mpc_show(struct seq_file *m, void *v)
 			seq_printf(m, "   %-3d  %-3d",
 				   in_entry->shortcut->vpi,
 				   in_entry->shortcut->vci);
-		seq_printf(m, "\n");
+		seq_putc(m, '\n');
 	}
 
 	seq_printf(m,
@@ -185,9 +185,9 @@ static int mpc_show(struct seq_file *m, void *v)
 			seq_printf(m, " %-3d %-3d",
 				   eg_entry->shortcut->vpi,
 				   eg_entry->shortcut->vci);
-		seq_printf(m, "\n");
+		seq_putc(m, '\n');
 	}
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 
-- 
2.12.2
