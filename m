From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] atm: Use seq_puts() in lec_info()
Date: Sun, 21 May 2017 22:17:31 +0200
Message-ID: <4cd2b4a4-135a-0b79-9025-061c313d6cff@users.sourceforge.net>
References: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 21:49:10 +0200

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index ca3aec0c0743..752891434074 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -804,7 +804,7 @@ static void lec_info(struct seq_file *seq, struct lec_arp_table *entry)
 	if (entry->vcc)
 		seq_printf(seq, "%3d %3d ", entry->vcc->vpi, entry->vcc->vci);
 	else
-		seq_printf(seq, "        ");
+		seq_puts(seq, "        ");
 	if (entry->recv_vcc) {
 		seq_printf(seq, "     %3d %3d", entry->recv_vcc->vpi,
 			   entry->recv_vcc->vci);
-- 
2.13.0

