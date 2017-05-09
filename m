From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/4] net: stmmac: Use seq_putc() in sysfs_display_ring()
Date: Tue, 9 May 2017 13:54:52 +0200
Message-ID: <adf65033-79bd-ed8d-57e1-6c7c1460a009@users.sourceforge.net>
References: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa58027a-a39c-963e-4376-a4d5312ee118@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 13:24:27 +0200

A single character (line break) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1f7022ce78b7..4fa95234978c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3730,7 +3730,7 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 				   le32_to_cpu(p->des2), le32_to_cpu(p->des3));
 			p++;
 		}
-		seq_printf(seq, "\n");
+		seq_putc(seq, '\n');
 	}
 }
 
-- 
2.12.2
