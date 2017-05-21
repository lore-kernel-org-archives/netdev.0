From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] atm: Use seq_putc() in lec_info()
Date: Sun, 21 May 2017 22:18:35 +0200
Message-ID: <b8b850c0-4a70-c36e-dffa-0e7ea27498fb@users.sourceforge.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 21:50:44 +0200

A single space character should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 752891434074..1d4edf093987 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -796,7 +796,7 @@ static void lec_info(struct seq_file *seq, struct lec_arp_table *entry)
 
 	for (i = 0; i < ETH_ALEN; i++)
 		seq_printf(seq, "%2.2x", entry->mac_addr[i] & 0xff);
-	seq_printf(seq, " ");
+	seq_putc(seq, ' ');
 	for (i = 0; i < ATM_ESA_LEN; i++)
 		seq_printf(seq, "%2.2x", entry->atm_addr[i] & 0xff);
 	seq_printf(seq, " %s %4.4x", lec_arp_get_status_string(entry->status),
-- 
2.13.0
